local ok, cmp = pcall(require, 'cmp')
if ok then cmp.register_source('en_hint', require('cmp_en_hint').new()) end
