classdef phasor < handle
    % phasor   Phasor representation for impedance analysis
    % The phasor class enables impedance analysis seamlessly.
    % Phasor instances follow the rules of phasor arithmetic
    % using the usual Matlab operators +, *, /, etc!
    % The phasor can be defined in either polar 'pol' or
    % rectangular/Cartesian 'rec' form.
    % The phasor can be accessed in either form, too!
    % Even symbolic phasor objects can be constructed.
    %
    % Usage: 
    %   - Construct:
    %       p1 = phasor(coords,c1,c2)
    %       where:
    %       coords is either 'pol' or 'rec'
    %       c1 is either the radius or real part
    %       c2 is either the angle or imaginary part
    %   - Access:
    %       p1.pol % polar form of p1
    %       p1.rec % rectangular form of p1
    %   - Operate:
    %       All the usual arithmetic operators work, like:
    %       p1+p2 % sum phasors
    %       p1-p2 % subtract phasors
    %       p1*p2 % multiply phasors
    %       p1/p2 % divide phasors
    %       a*p1 % scale a phasor
    %
    % phasor Properties:
    %    pol - polar form representation [radius,angle]
    %    rec - rectangular form as complex number
    properties
        pol % polar form representation [radius,angle]
        rec % rectangular form as complex number
    end
    methods
        function obj = phasor(coords,c1,c2)
            if nargin > 0
                switch coords
                    case 'pol'
                        obj.pol = [c1,c2]; % r, theta
                        obj.rec = pol2rec(obj);
                    case 'rec'
                        obj.rec = c1+1j*c2; % x + j y
                        obj.pol = rec2pol(obj);
                    otherwise
                        error('Either pol or rec coordinates')
                end

            end
        end
        function c_rec = pol2rec(obj)
            c_rec1 = obj.pol(1)*cos(obj.pol(2)) + 1j*obj.pol(1)*sin(obj.pol(2));
            c_rec = simplify(rewrite(c_rec1,'sqrt'));
        end
        function c_pol = rec2pol(obj)
            c_pol =  rewrite( ...
                simplify( ...
                    [sqrt(real(obj.rec)^2 + imag(obj.rec)^2), ...
                    atan2(imag(obj.rec),real(obj.rec))] ...
                ), ...
                'sqrt' ...
            );
        end
        function out = plus(obj1,obj2)
            sum = phasor.simp_rec(obj1.rec + obj2.rec);
            out = phasor('rec',real(sum),imag(sum));
        end
        function out = minus(obj1,obj2)
            sum = simp_rec(obj1.rec - obj2.rec);
            out = phasor('rec',real(sum),imag(sum));
        end
        function out = uminus(obj1)
            sum = -obj1.rec;
            out = phasor('rec',real(sum),imag(sum));
        end
        function out = mtimes(obj1,obj2)
            if isa(obj1,'phasor')
                if isa(obj2,'phasor')
                    pro = [obj1.pol(1)*obj2.pol(1), ...
                        obj1.pol(2)+obj2.pol(2)];
                else
                    if isreal(obj2)
                        pro = [obj1.pol(1)*obj2, ...
                            obj1.pol(2)];
                    else
                        error('phasor scalar multiplication supports reals only')
                    end
                end
            elseif isa(obj2,'phasor')
                if isreal(obj1)
                    pro = [obj2.pol(1)*obj1, ...
                        obj2.pol(2)];
                else
                    error('phasor scalar multiplication supports reals only')
                end
            end
            pro = simplify(pro);
            out = phasor('pol',pro(1),pro(2));
        end
        function out = times(obj1,obj2)
            out = mtimes(obj1,obj2);
        end
        function out = mrdivide(obj1,obj2)
            if isa(obj1,'phasor')
                if isa(obj2,'phasor')
                    pro = [obj1.pol(1)/obj2.pol(1), ...
                        obj1.pol(2)-obj2.pol(2)];
                else
                    if isreal(obj2)
                        pro = [obj1.pol(1)/obj2, ...
                            obj1.pol(2)];
                    else
                        error('phasor scalar division supports reals only')
                    end
                end
            elseif isa(obj2,'phasor')
                if isreal(obj1)
                    pro = [obj1/obj2.pol(1), ...
                        -1*obj2.pol(2)];
                else
                    error('phasor scalar division supports reals only')
                end
            end
            pro = simplify(pro);
            out = phasor('pol',pro(1),pro(2));
        end
        function out = rdivide(obj1,obj2)
            out = mrdivide(obj1,obj2);
        end
        function out = mpower(obj1,pow)
            pro = [obj1.pol(1)^pow, ...
                obj1.pol(2)*pow];
            out = phasor('pol',pro(1),pro(2));
        end
        function out = power(obj1,pow)
            out = mpower(obj1,pow);
        end
    end
    methods(Static)
        function phasor_ex = sym2phasor(sym_ex,subs_struc)
            sym_str = string(simplify(sym_ex));
            names = fieldnames(subs_struc);
            for i=1:length(names)
                eval([names{i} '=subs_struc.' names{i} ';']);
            end
            phasor_ex = eval(sym_str);
        end
        function out = simp_rec(rec_ex)
            % simplify rectangular forms ... avoids abs
            out = simplify(rewrite(rec_ex,'sqrt'));
        end
    end
end