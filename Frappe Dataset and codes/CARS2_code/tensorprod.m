function c=tensorprod(a,W,b)
% a: d-dim vector
% W: d*D*d tensor
% b: d-dim vector

[M,N,K]=size(W);
c=reshape(a*reshape(W,[M N*K]),[N,K])*b';