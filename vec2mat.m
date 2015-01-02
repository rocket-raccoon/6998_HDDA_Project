function mat = vec2mat(vec, matCol)
error(nargchk(2, 3, nargin,'struct'));	% 2 or 3 inputs required
if ndims(vec) > 2
    error(message('comm:vec2mat:InvalidVec'));
elseif (length(matCol) ~= 1 || ~isfinite(matCol) || ~isreal(matCol)...
        || floor(matCol) ~= matCol || matCol < 1)
    error(message('comm:vec2mat:InvalidMatcol'));
end

[vecRow, vecCol] = size(vec);
vecLen = vecRow*vecCol;
if vecCol == matCol
    mat = vec;
    padded = 0;
    return;			% nothing to do
elseif vecRow > 1
    vec = reshape(vec.', 1, vecLen);
end

try
    if nargin < 3 || isempty(padding)
        padding = cast(0, class(vec));	% default padding
    else
        padding = cast(padding(:).', class(vec));
    end
catch exception
    throw(exception)
end
paddingLen = length(padding);

matRow = ceil(vecLen/matCol);
padded = matRow*matCol - vecLen;	% number of elements to be padded
vec = [vec, padding(1:min(padded, paddingLen)),...
       repmat(padding(paddingLen), 1, padded-paddingLen)];	% padding
mat = reshape(vec, matCol, matRow).';
end