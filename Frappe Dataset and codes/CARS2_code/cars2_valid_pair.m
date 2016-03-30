clear;
load('cars2_frappe_datasplit');
load('cars2_frappe_negids');
load('cars2_frappe_randitem.mat');
Traindata(:,3)=negids;
Traindata=double(Traindata);
Validdata=double(Validdata);
M=max(Traindata(:,1));
N=max(Traindata(:,2));
N=max(N,max(Traindata(:,3)));
K=max(Traindata(:,4));

d=10;
dc=4;
Dq=[2 4 6 8 10 12 14 16]; % Choose values to run 
dp=2;
%dq=5;
lamb1=0.001;
lamb2=0.001;
lamb3=0.001;
gamma=0.01;
numiter=30;
topn=10;
relval=1;



ninst=length(Traindata(:,1));
fid=fopen('CARS2_FRP_Valid_Pair_Dq.txt','wt');
for z=1:length(Dq);
    dq=Dq(z);
    fprintf(fid,'%s %d\n', 'dq=',dq);
    U=0.1*randn(M,d); % latent user factors
    V=0.1*randn(N,d);	% latent item factors
    C=0.1*randn(K,dc);	% latent context factors
    W=0.1*randn(d,dp,dc); 	% latent space user-context mapping
    Z=0.1*randn(d,dq,dc);	% latent space item-context mapping
    A=0.1*randn(N,dp);		% latent item factors under context-aware user space
    B=0.1*randn(M,dq);		% latent user factors under context-aware item space
    for n=1:numiter
        s=0;
        for i=1:ninst
            % Gradients
            pik=tensorprod(U(Traindata(i,1),:),W,C(Traindata(i,4),:));
            qjk=tensorprod(V(Traindata(i,2),:),Z,C(Traindata(i,4),:));
            qsk=tensorprod(V(Traindata(i,3),:),Z,C(Traindata(i,4),:));
            e=U(Traindata(i,1),:)*(V(Traindata(i,2),:)'-V(Traindata(i,3),:)')...
                +(A(Traindata(i,2),:)-A(Traindata(i,3),:))*pik+B(Traindata(i,1),:)*(qjk-qsk);
            e=logf(e)-1;
            du=e*(V(Traindata(i,2),:) -V(Traindata(i,3),:)...
                +(reshape(reshape(W,[d*dp,dc])*C(Traindata(i,4),:)',[d,dp])*(A(Traindata(i,2),:)'-A(Traindata(i,3),:)'))')...
                +lamb1*U(Traindata(i,1),:);
            dvj=e*(U(Traindata(i,1),:)+(reshape(reshape(Z,[d*dq,dc])*C(Traindata(i,4),:)',[d,dq])*B(Traindata(i,1),:)')')...
                +lamb1*V(Traindata(i,2),:);
            dvs=e*(-U(Traindata(i,1),:)-(reshape(reshape(Z,[d*dq,dc])*C(Traindata(i,4),:)',[d,dq])*B(Traindata(i,1),:)')')...
                +lamb1*V(Traindata(i,3),:);
            dx=e*((reshape(reshape(permute(W,[3,2,1]),[dc*dp,d])*U(Traindata(i,1),:)',[dc,dp])*(A(Traindata(i,2),:)'-A(Traindata(i,3),:)'))'...
                +(reshape(reshape(permute(Z,[3,2,1]),[dc*dq,d])*(V(Traindata(i,2),:)'-V(Traindata(i,3),:)'),[dc,dq])*B(Traindata(i,1),:)')')...
                +lamb1*C(Traindata(i,4),:);
            dw=zeros(d,dp,dc);
            for m=1:dp
                dw(:,m,:)=reshape(e*(A(Traindata(i,2),m)-A(Traindata(i,3),m))*(U(Traindata(i,1),:)'*C(Traindata(i,4),:)),[d,1,dc])...
                    +lamb2*W(:,m,:);
            end
            dz=zeros(d,dq,dc);
            for m=1:dq
                dz(:,m,:)=reshape(e*B(Traindata(i,1),m)*((V(Traindata(i,2),:)'-V(Traindata(i,3),:)')*C(Traindata(i,4),:)),[d,1,dc])...
                    +lamb2*Z(:,m,:);
            end
            daj=e*pik'+lamb3*A(Traindata(i,2),:);
            das=e*(-pik')+lamb3*A(Traindata(i,3),:);
            dbi=e*(qjk'-qsk')+lamb3*B(Traindata(i,1),:);
            
            % Update
            U(Traindata(i,1),:)=U(Traindata(i,1),:)-gamma*du;
            V(Traindata(i,2),:)=V(Traindata(i,2),:)-gamma*dvj;
            V(Traindata(i,3),:)=V(Traindata(i,3),:)-gamma*dvs;
            C(Traindata(i,4),:)=C(Traindata(i,4),:)-gamma*dx;
            W=W-gamma*dw;
            Z=Z-gamma*dz;
            A(Traindata(i,2),:)=A(Traindata(i,2),:)-gamma*daj;
            A(Traindata(i,3),:)=A(Traindata(i,3),:)-gamma*das;
            B(Traindata(i,1),:)=B(Traindata(i,1),:)-gamma*dbi;
            if mod(n,1)==0
                s=s-log(e+1);
            end
        end
        % Evaluate
        if mod(n,1)==0
            s=s+0.5*(lamb1*(sum(sum(U.^2))+sum(sum(V.^2))+sum(sum(C.^2)))+lamb2*(sum(sum(sum(W.^2))+sum(sum(sum(Z.^2)))))...
                +lamb3*(sum(sum(A.^2))+sum(sum(B.^2))));
            ap=0;
            prec=0;
            Kts=0;
            temp=U*V';
            for k=1:K
                ind=find(Validdata(:,4)==k);
                if ~isempty(ind)
                    ts=sparse(Validdata(ind,1),Validdata(ind,2),Validdata(ind,3),M,N);
                    indtr=find(Traindata(:,4)==k);
                    if ~isempty(indtr)
                        tr=sparse(Traindata(indtr,1),Traindata(indtr,2),Traindata(indtr,3),M,N);
                    else
                        tr=sparse(M,N);
                    end
                    pk=reshape(reshape(U*reshape(W,[d dp*dc]),[M*dp,dc])*C(k,:)',[M,dp]);
                    qk=reshape(reshape(V*reshape(Z,[d dq*dc]),[N*dq,dc])*C(k,:)',[N,dq]);
                    pred=temp+pk*A'+B*qk';
                    %                 pred=temp;
                    pred(tr>0)=0;
                    for j=1:M
                        ind=find(ts(j,:)>0);
                        if length(ind)>0
                            indtest=union(ind,indrand);
                            [a,f] = map_metric(pred(j,indtest),ts(j,indtest),relval);
                            ap=ap+f;
                            [a,f]=prec_metric(pred(j,indtest),ts(j,indtest),topn,relval);
                            prec=prec+f;
                            Kts=Kts+1;
                        end
                    end
                end
            end
            fprintf(fid,'%s %d %s %8.6f %s %8.6f %s %8.6f\n','niter=',n,'Obj=',s,'MAP=',ap/Kts,'Prec=',prec/Kts);
        end
    end
end
quit



