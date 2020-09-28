
Make sure the `rico` directory is in your Matlab path.


```matlab
addpath('../rico')
```

# `phasor` docs

The following is the source code.

```{=latex}
\inputminted{matlab}{../rico/phasor.m}
```

# `tf_factor` docs

The following is the source code.
```{=latex}
\inputminted{matlab}{../rico/tf_factor.m}
```

## Usage and examples

# `bode_multi` docs

The following is the source code.

\inputminted{matlab}{../rico/bode_multi.m}

## Usage and examples


```matlab
sys = tf([5,3,5],[1,6,1,20])
```

    
    sys =
     
        5 s^2 + 3 s + 5
      --------------------
      s^3 + 6 s^2 + s + 20
     
    Continuous-time transfer function.
    



```matlab
sys_a = tf_factor(sys)
```

    
    sys_a(:,:,1,1) =
     
              3.155
      ----------------------
      s^2 - 0.3399 s + 3.155
     
    
    sys_a(:,:,2,1) =
     
        6.34
      --------
      s + 6.34
     
    
    sys_a(:,:,3,1) =
     
      s^2 + 0.6 s + 1
     
    
    sys_a(:,:,4,1) =
     
      0.25
     
    4x1 array of continuous-time transfer functions.
    



```matlab
% [f,ax_mag,ax_phase] = bode_multi(G); % get axis handles
f = bode_multi(sys_a);

hgsave(f,'figures/temp');
```
\begin{figure}
\centering
\input{figures/bode_multi_docs.tex}
\caption{a bode multi example output.}
\label{fig:bode_multi_docs}
\end{figure}
# `pole` docs

The following is the source code.

\inputminted{matlab}{../rico/pole.m}

## Usage and examples

# `zero` docs

The following is the source code.

\inputminted{matlab}{../rico/zero.m}

## Usage and examples

# `tf2latex` docs

The following is the source code.

\inputminted{matlab}{../rico/tf2latex.m}

## Usage and examples
