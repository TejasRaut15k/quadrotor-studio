function angle = quadrotorWrapToPi(angle)
%QUADROTORWRAPTOPI Wrap an angle to [-pi, pi].

angle = mod(angle + pi, 2 * pi) - pi;

end
