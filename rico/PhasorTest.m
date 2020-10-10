classdef PhasorTest < matlab.unittest.TestCase
    methods(Test)
        function testNumericCase1(testCase)
            foo = phasor('rec',4,8);
            actSolution = foo.pol;
            expSolution = [sqrt(4^2+8^2),atan2(8,4)];
            testCase.verifyEqual(actSolution,expSolution)
        end
        function testNumericCase2(testCase)
            foo = phasor('pol',3,pi);
            actSolution = foo.rec;
            expSolution = complex(-3,0);
            testCase.verifyEqual(actSolution,expSolution,'AbsTol',1e-12)
        end
        function testSymbolicCase1(testCase)
            syms R C w ZR ZC A VS % symbolic variables
            assume([R,C,w] >= 0) % assume nonnegative
            assume(A>0)
            plist_phasor.ZR = phasor('pol',R,0);
            plist_phasor.ZC = phasor('pol',1/(w*C),-pi/2);
            plist_phasor.VS = phasor('pol',A,0);
            vo = ZC/(ZC+ZR) * VS;
            vo_phasor = phasor.sym2phasor(vo,plist_phasor);
            actSolution = vo_phasor.pol;
            expSolution = [ A/(C^2*R^2*w^2 + 1)^(1/2), -atan(C*R*w)];
            testCase.verifyEqual(actSolution,expSolution)
        end
        function testSymbolicCase2(testCase)
            syms R1 R2 L w ZR1 ZR2 ZL A VS % symbolic variables
            assume([R1,R2,L,w,A] > 0) % assume positive
            assume(w>=0) % assume nonnegative
            plist_phasor.ZR1 = phasor('pol',R1,0);
            plist_phasor.ZR2 = phasor('pol',R2,0);
            plist_phasor.ZL = phasor('pol',w*L,pi/2);
            plist_phasor.VS = phasor('pol',A,0); % sine phasor
            Ze = 1/(1/ZL + 1/ZR2);
            vo = simplify(Ze/(Ze+ZR1) * VS);
            vo_phasor = phasor.sym2phasor(vo,plist_phasor);
            actSolution = vo_phasor.pol;
            expSolution = [ ...
                (A*L*R2*w)/(R1^2*R2^2 + L^2*w^2*(R1 + R2)^2)^(1/2), ...
                pi/2 - atan((L*w*(R1 + R2))/(R1*R2)) ...
            ];
            testCase.verifyEqual(actSolution,expSolution)
        end
        function testSymbolicCase3(testCase)
            % this one has N which is not declared a phasor when applying
            % sym2phasor ... shows the warning that should be displayed
            % Define symbolic variables
            syms vL vRL vRS v1 v2 VS
            syms iL iRL iRS i1 i2
            syms N real
            syms ZL ZRL ZRS
            % Define the equations
            eqs = [ ...
                vL == iL*ZL, ...
                vRS == iRS*ZRS, ...
                vRL == iRL*ZRL, ...
                v2 == N*v1, ...
                i2 == -1/N*i1, ...
                i1 == iRS, ...
                i2 == -iL, ...
                iL == iRL, ...
                VS == vRS + v1, ...
                v2 == vL + vRL ...
            ];
            % Solve the system of equations
            sol = solve(eqs,[vL,vRS,vRL,v1,v2,iL,iRS,iRL,i1,i2]);
            % Define impedances
            syms w A RL RS L
            assume([w,A,RL,RS,L,N]>0)
            phasor_list.ZRL = phasor('rec',RL,0);
            phasor_list.ZRS = phasor('pol',RS,0);
            phasor_list.ZL = phasor('pol',w*L,pi/2);
            phasor_list.VS = phasor('pol',A,0);
            % substitute into the symbolic sol
            vRL_expanded = phasor.sym2phasor(sol.vRL,phasor_list);
            % verify
            actSolution = vRL_expanded.pol;
            expSolution = [ ...
                (A*RL*abs(N))/((RS*N^2 + RL)^2 + L^2*w^2)^(1/2), ...
                -atan((L*w)/(RS*N^2 + RL)) ...
            ];
            testCase.verifyEqual(actSolution,expSolution)
        end
    end
end