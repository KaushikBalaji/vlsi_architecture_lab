N = 16;
scale = 2^14;

for i = 0:N-1
    val = round(atan(2^-i) * scale);
    fprintf("atan_table[%d] = 16'd%d;\n", i, val);
end