function [out,ax1,ax2] = bode_multi(sys_a)

syms s

if ~isa(sys_a,'tf')
  sys_a = tf(sys_a);
end
n = length(sys_a); % > 1 if system model array

out = figure;
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
omega_a = {.1,1};
mag_lims = [0,1];
phase_lims = [-90,0];
for i = 1:n
  sys = sys_a(1,1,i);
  [mag,phase,omega] = bode(sys);
  if omega(1) < omega_a{1}
    omega_a{1} = omega(1);
  end
  if omega(end) > omega_a{end}
    omega_a{end} = omega(end);
  end
  if mag_lims(1) < mag_lims(1)
    mag_lims(1) = mag_lims(1);
  end
  if mag_lims(2) > mag_lims(2)
    mag_lims(2) = mag_lims(2);
  end
  if phase_lims(1) < phase_lims(1)
    phase_lims(1) = phase_lims(1);
  end
  if phase_lims(2) > phase_lims(2)
    phase_lims(2) = phase_lims(2);
  end
end

olog = num2cell(cellfun(@(x) log10(x),omega_a));
omega = logspace(olog{:},100);

for i = 1:n
  sys = sys_a(1,1,i);
  [mag,phase] = bode(sys,omega);
  mag = squeeze(mag);
  phase = squeeze(phase);
  % size(omega)
  % omega = squeeze(omega);
  axes(ax1);
  hold on;
  [num,den] = tfdata(sys);
  sys_sym = poly2sym(cell2mat(num),s)/poly2sym(cell2mat(den),s);
  semilogx(...
    omega,db(mag),...
    'linewidth',1,...
    'displayname',['$',latex(sys_sym),'$']...
  );
  ylabel('|H(j\omega)|, dB')
  axes(ax2);
  hold on;
  semilogx(omega,phase,'linewidth',1);
  xlabel('frequency \omega, rad/s')
  ylabel('\angle{H(j\omega)}, deg')
  h = findobj(gcf,'type','line');
  set(h,'linewidth',1);
end
% log scale
ax1.XScale = 'log';
ax2.XScale = 'log';
% adjust limits and ticks
mag_tick_array = ax1.YLim(1):20:ax1.YLim(2);
[m0db,i0db_a] = min(abs(mag_tick_array));
i0db = i0db_a(1); % first index closest to zero
mag_tick_array = mag_tick_array-mag_tick_array(i0db);
ax1.YTick = mag_tick_array;
phase_tick_array = ax2.YLim(1):45:ax2.YLim(2);
[p0db,i0_a] = min(abs(phase_tick_array));
i0 = i0_a(1); % first index closest to zero
phase_tick_array = phase_tick_array-phase_tick_array(i0);
ax2.YTick = phase_tick_array;
% grid lines
ax1.XGrid = 'on';
ax1.YGrid = 'on';
ax2.XGrid = 'on';
ax2.YGrid = 'on';
% legend
axP = get(ax1,'Position'); % so we can keep size
l = legend(ax1,'show');
l.Interpreter = 'latex';
l.Location = 'northeastoutside';
ax1.Position = axP; % reset size