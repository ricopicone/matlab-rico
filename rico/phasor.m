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
            c_rec2 = phasor.simp_sym(c_rec1);
            try % in case it's just a number
                c_rec = double(c_rec2);
            catch
                c_rec = c_rec2;
            end
        end
        function c_pol = rec2pol(obj)
            rec_ex = obj.rec;
            c_pol1 =  phasor.simp_sym( ...
                [sqrt(real(rec_ex)^2 + imag(rec_ex)^2), ...
                atan(imag(rec_ex)/real(rec_ex))] ...
            );
            try % in case it's just a number
                c_pol = double(c_pol1);
            catch
                c_pol = c_pol1;
            end
        end
        function out = plus(obj1,obj2)
            sum = phasor.simp_sym(obj1.rec + obj2.rec);
            out = phasor('rec',real(sum),imag(sum));
        end
        function out = minus(obj1,obj2)
            sum = phasor.simp_sym(obj1.rec - obj2.rec);
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
            pro = phasor.simp_sym(pro);
            try % in case it's just a number
                pro = double(pro);
            catch
                pro = pro;
            end
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
            pro = phasor.simp_sym(pro);
            try % in case it's just a number
                pro = double(pro);
            catch
                pro = pro;
            end
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
            sym_str = string(simplify(sym(sym_ex)));
            syms_all = symvar(sym(sym_ex));
            names = fieldnames(subs_struc);
            for i=1:length(syms_all)
                if ismember(syms_all(i),names)
                    eval([char(syms_all(i)) '=subs_struc.' char(syms_all(i)) ';']);
                else
                    warning(['variable ' char(syms_all(i)) ' has been assumed to be real.'])
                    eval(['syms ' char(syms_all(i)) ' real']);
                    eval([char(syms_all(i)) '=phasor("rec",' char(syms_all(i)) ',0);']);
                end
            end
            phasor_ex = eval(sym_str);
            phasor_ex = phasor.simplify_pol(phasor_ex);
        end
        function out = simp_sym(rec_ex)
            % simplify rectangular forms ... avoids abs
            % NOT FOR PHASORS
            out = simplify(rewrite(sym(rec_ex),'sqrt'));
            try % in case it's just a number
                out = double(out);
            catch
                out = out;
            end
        end
        function out = simplify_rec(my_phasor)
            % simplifies a phasor rec (and therefore pol) 
            sim = phasor.simp_sym(my_phasor.rec);
            out = phasor('rec',real(sim),imag(sim));
        end
        function out = simplify_pol(my_phasor)
            % simplifies a phasor pol (and therefore rec) 
            sim = phasor.simp_sym(my_phasor.pol);
            out = phasor('pol',sim(1),sim(2));
        end
    end
end