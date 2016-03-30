function [prec,val]=prec_metric(rankmat,groundtruth,topn,relval)

if any(any(groundtruth))
    [M,N]=size(groundtruth);
    indtest=find (sum(groundtruth,2)>0);
    prec=zeros(M,1);
    k=0;
    for n=1:length(indtest)
        i=indtest(n);

        [p,r,vad]=precesionrecall(rankmat(i,:),groundtruth(i,:),topn,relval);
        prec(i)=p;
        k=k+1;
    end
    val=sum(prec)/k;
else
    val=-1;
end