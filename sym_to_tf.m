function tf_obj = sym_to_tf(sym_tf,s_var)
  % TODO test to make sure s_var is in symvar(sym_tf) ...
  syms(symvar(sym_tf))
  syms s
  sym_tf = subs(sym_tf,s_var,s);
  tf_str = char(sym_tf);
  s = tf([1,0],[1]);
  eval(['tf_obj = ',tf_str,';']);