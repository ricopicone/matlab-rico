function out = tf_factor(sys)
% TF_FACTOR  factors a transfer function TF object
%   SYS_ARRAY = TF_FACTOR(SYS) factors SYS into
%   constant, real pole/zero, and 
%   conjugate pole/zero pair sub-TF models. 
%   It returns a TF model array. 
%   The last entry is the appropriate gain.
%   The product of entries of the model array 
%   should equal sys.
%   
%   Dependencies:
%     - matlab-rico functions
%       - POLE 
%       - ZERO
%     - toolboxes
%       - Control Systems
%
%   Example:
%
%   sys=tf(...
%     [-0.64 -0.4101 0.00783],...
%     [1 1.489 0.7681 0.09455 0.0424 .7]...
%   );
%   tf_factor(sys)
%   
%   source: https://github.com/ricopicone/matlab-rico
%   
%   See also TF, STACK.

if ~isa(sys,'tf')
  sys = tf(sys);
end

% extract poles and zeros
poles=pole(sys);
zeros=zero(sys);

% make sure they're in coupled pairs
poles_cplx = cplxpair(poles);
zeros_cplx = cplxpair(zeros);

% loop through and extract sub-tfs into model array, each in standard form, keeping track of the gain
F = stack(1,tf(1,1)); % init model array
num_gain = sys.Num{:}(...
  find(cell2mat(sys.Num),1,'first')...
); % gain of numerator
den_gain = sys.Den{:}(...
  find(cell2mat(sys.Den),1,'first')...
); % gain of denominator
F_gain = num_gain/den_gain;
F_gain_o = F_gain ; % original gain
k=1;
jskip=0;
% poles first
for j=1:length(poles_cplx)
  if ~jskip
    if ~isreal(poles_cplx(j))
      F(:,:,k) = zpk([],[poles_cplx(j),poles_cplx(j+1)],poles_cplx(j)*poles_cplx(j+1));
      F_gain = F_gain/abs(poles_cplx(j)*poles_cplx(j+1));
      jskip=1;% skip next index
    else
      F(:,:,k) = zpk([],poles_cplx(j),abs(poles_cplx(j)));
      F_gain = F_gain/abs(poles_cplx(j));
      jskip=0;
    end
    k=k+1;
  else
    jskip=0;
  end
end
% now zeros
for j=1:length(zeros_cplx)
  if ~jskip
    if ~isreal(zeros_cplx(j))
      F(:,:,k) = zpk([zeros_cplx(j),zeros_cplx(j+1)],[],1/(zeros_cplx(j)*zeros_cplx(j+1)));
      F_gain = F_gain*abs(zeros_cplx(j)*zeros_cplx(j+1));
      jskip=1;% skip next index
    else
      F(:,:,k) = zpk(zeros_cplx(j),[],1/abs(zeros_cplx(j)));
      F_gain = F_gain*abs(zeros_cplx(j));
      jskip=0;
    end
    k=k+1;
  else
    jskip=0;
  end
end
F(:,:,k) = F_gain; % drop the overall gain into the model array

% check by concatenation
tf_composite = 1;
for j=1:k
  tf_composite = tf_composite*F(:,:,j);
end
num_gain = sys.Num{:}(find(cell2mat(tf_composite.Num),1,'first'));
den_gain = sys.Den{:}(find(cell2mat(tf_composite.Den),1,'first'));
if (... % check that the factorization is correct
  isequal(num_gain/den_gain,F_gain_o) && ... % gain
  round(sum(poles),5) == round(sum(pole(tf_composite)),5) && ... % poles ... not perfect
  round(sum(zeros),5) == round(sum(zero(tf_composite)),5) ... % zeros ... not perfect
)
  out = F;
else
  error('composite check failed!')
  out = 1;
end