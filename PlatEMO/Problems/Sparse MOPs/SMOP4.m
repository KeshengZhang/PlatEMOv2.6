classdef SMOP4 < PROBLEM
% <problem> <Sparse MOP>
% Benchmark MOP with sparse Pareto optimal solutions
% theta --- 0.1 --- Sparsity of the Pareto set

%------------------------------- Reference --------------------------------
% Y. Tian, X. Zhang, C. Wang, and Y. Jin, An evolutionary algorithm for
% large-scale sparse multi-objective optimization problems, IEEE
% Transactions on Evolutionary Computation, 2019.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    properties(Access = private)
        theta = 0.1;    % Sparsity of the Pareto set
    end
    methods
        %% Initialization
        function obj = SMOP4()
            obj.theta = obj.Global.ParameterSet(0.1);
            if isempty(obj.Global.M)
                obj.Global.M = 2;
            end
            if isempty(obj.Global.D)
                obj.Global.D = 100;
            end
            obj.Global.lower    = [zeros(1,obj.Global.M-1)+0,zeros(1,obj.Global.D-obj.Global.M+1)-1];
            obj.Global.upper    = [zeros(1,obj.Global.M-1)+1,zeros(1,obj.Global.D-obj.Global.M+1)+2];
            obj.Global.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,X)
            [N,D] = size(X);
            M = obj.Global.M;
            K = ceil(obj.theta*(D-M+1));
            g = sort(g3(X(:,M:end),0),2);
            g = sum(g(:,1:D-M-K+1),2);
            PopObj = repmat(1+g/(D-M+1),1,M).*fliplr(cumprod([ones(N,1),1-cos(X(:,1:M-1)*pi/2)],2)).*[ones(N,1),1-sin(X(:,M-1:-1:1)*pi/2)];
        end
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            M = obj.Global.M;
            P = UniformPoint(N,M);
            c = ones(size(P,1),M);
            for i = 1 : size(P,1) 
                for j = 2 : M
                    temp = P(i,j)/P(i,1)*prod(1-c(i,M-j+2:M-1));
                    c(i,M-j+1) = (temp^2-temp+sqrt(2*temp))/(temp^2+1);
                end
            end
            x = acos(c)*2/pi;
            P = fliplr(cumprod([ones(size(x,1),1),1-cos(x(:,1:end-1)*pi/2)],2)).*[ones(size(x,1),1),1-sin(x(:,end-1:-1:1)*pi/2)];
        end
    end
end

function g = g3(x,t)
    g = 4-(x-t)-4./exp(100*(x-t).^2);
end