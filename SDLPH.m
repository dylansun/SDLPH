function [G, F, B] = SDLPH(X,y,B,gmap,Fmap,alpha, tol,maxItr,debug)

% ---------- Argument defaults ----------
if ~exist('debug','var') || isempty(debug)
    debug=1;
end
if ~exist('tol','var') || isempty(tol)
    tol=1e-5;
end
if ~exist('maxItr','var') || isempty(maxItr)
    maxItr=1000;
end
nu = Fmap.nu;
delta = 1/nu;
% ---------- End ----------

nbits = size(B,2);
saved_Laplacian = ['model/L_' num2str(nbits) '.mat'];
if ~exist('model', 'dir')
    mkdir('model');
end
if ~exist(saved_Laplacian, 'file')
    L = adjMatrix(y);
    L = double((L));
    [V,D] = eigs(L, nbits);
    M = V*sqrt(D);
    save(saved_Laplacian, 'M','L');
else
    load(saved_Laplacian);
end

% label matrix N x c
if isvector(y) 
    Y = sparse(1:length(y), double(y), 1); Y = full(Y);
else
    Y = y;
end


% G-step
switch gmap.loss
    case 'L2'
        [Wg, ~, ~] = RRC(B, Y, gmap.lambda); % (Z'*Z + gmap.lambda*eye(nbits))\Z'*Y;
    case 'Hinge'
        svm_option = ['-q -s 4 -c ', num2str(1/gmap.lambda)];
        model = train(double(y),sparse(B),svm_option);
        Wg = model.w';
end
G.W = Wg;

% F-step

[WF, ~, ~] = RRC(X, B, Fmap.lambda);

F.W = WF; F.nu = nu;


i = 0; 
while i < maxItr    
    i=i+1;  
    
    if debug,fprintf('Iteration  %03d: \n',i);end
    
    % B-step
  
        XF = X*WF;
   
    switch gmap.loss
        case 'L2'
            Q = nu*XF + Y*Wg';
            B = zeros(size(B));          
            for time = 1:10
               if debug,fprintf('Iteration  %03d, iterately updated B %d/10: \n',i, time);end
               Z0 = B;
                for k = 1 : size(B,2)
                    
                    Zk = B; 
                    Zk(:,k) = [];
                    
                    % The k th row of W
                    Wkk = Wg(k,:); 
                    
                    % W exclude k th row
                    Wk = Wg; 
                    Wk(k,:) = [];                    
                    
                    % do the same for M 
                    Mkk = M(:,k);
                    Mk = M;
                    Mk(:,k) = [];
                    
                    %B(:,k) = sign(Q(:,k));
                    B(:,k) = sign(Q(:,k) -  Zk*(alpha * Mk'*Mkk+Wk*Wkk') );
                    %norm(Mk'*Mkk, 'fro')
                    %norm(Wk*Wkk', 'fro')
                     if debug,fprintf('Iteration  %03d, iterately updated B %d/10 %d/%d bit: \n',i, time, k, size(B,2));end
                end
                
                if norm(B-Z0,'fro') < 1e-6 * norm(Z0,'fro')
                    break
                end
            end
        case 'Hinge' 
            
            for ix_z = 1 : size(B,1)
                w_ix_z = bsxfun(@minus, Wg(:,y(ix_z)), Wg);
                B(ix_z,:) = sign(2*nu*XF(ix_z,:) + delta*sum(w_ix_z,2)');
            end
             
    end

    
    % G-step
    switch gmap.loss
    case 'L2'
        [Wg, ~, ~] = RRC(B, Y, gmap.lambda); % (Z'*Z + gmap.lambda*eye(nbits))\Z'*Y;
    case 'Hinge'        
        model = train(double(y),sparse(B),svm_option);
        Wg = model.w';
    end
    G.W = Wg;
    
    % F-step: update Projection matrix
    WF0 = WF;
    
    [WF, ~, ~] = RRC(X, B, Fmap.lambda);
   
    F.W = WF; F.nu = nu;
    
    bias = norm(B-X*WF,'fro');
    
    if debug, fprintf('Reconstruction error  bias=%g\n',bias); end
    if bias < tol*norm(B,'fro')
            break;
    end 
    
    if norm(WF-WF0,'fro') < tol * norm(WF0)
        break;
    end
end