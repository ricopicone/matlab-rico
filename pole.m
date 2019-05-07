function out = pole(sys)

out = roots(cell2mat(sys.Den));