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
    end
end