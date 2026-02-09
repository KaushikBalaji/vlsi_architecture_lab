clc;
clear;

% ---- Read HEX input file ----
fid = fopen('input.txt','r');
hex_cells = textscan(fid, '%s');
fclose(fid);

% Convert hex strings -> uint16 -> int16 -> int32
x_u16 = uint16(hex2dec(hex_cells{1}));
x = int32(typecast(x_u16, 'int16'));   % signed Q1.15

% ---- FIR coefficients (Q1.15 integers) ----
h0 = int32(868);
h1 = int32(15516);
h2 = int32(15516);
h3 = int32(868);

N = length(x);
y = zeros(N,1,'int32');

% Delay registers
x1 = int32(0);
x2 = int32(0);
x3 = int32(0);

for n = 1:N
    xin = x(n);

    mul_out0 = h0 * xin;    % 32 bits - Q(2.30)
    mul_out1 = h1 * x1;
    mul_out2 = h2 * x2;
    mul_out3 = h3 * x3;

    add_out0 = mul_out0 + mul_out1; % 33 bits - Q(3.30)
    add_out1 = add_out0 + mul_out2;
    add_out2 = add_out1 + mul_out3;

    y(n) = bitshift(add_out2 + int32(16384), -15);

    % Update delay line
    x3 = x2;
    x2 = x1;
    x1 = xin;
end

% Cast output to int16 (Q1.15)
% y = int16(y);
% y_q = round(y * 2^15);

% Saturate to int16 range
y(y >  32767) =  32767;
y(y < -32768) = -32768;
y = int16(y);



fprintf('Idx | Input(Hex) Input(Dec) Input(Float) | Output(Hex) Output(Dec) Output(Float)\n');
fprintf('--------------------------------------------------------------------------------\n');

for n = 1:N
    in_hex  = dec2hex(typecast(int16(x(n)),'uint16'),4);
    out_hex = dec2hex(typecast(y(n),'uint16'),4);

    fprintf('%3d |   %s      %6d       %+1.6f |    %s       %6d     %+1.6f\n', ...
        n, ...
        in_hex, int16(x(n)), double(x(n))/2^15, ...
        out_hex, y(n), double(y(n))/2^15);
end


fid = fopen('matlab_hexout_3.txt','w');
for n = 1:N
    fprintf(fid, '%04X\n', typecast(y(n),'uint16'));
end
fclose(fid);