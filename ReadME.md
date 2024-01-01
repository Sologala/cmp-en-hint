# 🏃cmp-en-hint

`cmp-en-hint` provides the English word completion functionality in Vim/Neovim.

The underlying working principle of `cmp-en-hint` is binary searching current typing word in pre-provided sorted [dictionary](./lua/cmp_en_hint/google-10000-english-usa.txt)

## Motivation and alternative
👏 There is an open-source plugin available to supplement English word usage.[cmp-look](https://github.com/octaltree/cmp-look).
However,it might not be compatible with Windows platforms due to its dependency on the "look" command from util-linux.
Additionally, using pipe call for dictionary queries can be inefficient when dealing with large dictionary files.
By loading and cacheing dictionary in memory with Lua and performing binary searches on sorted dictionaries, can achieve fast word completion.

## Demo
![](./.resource/screen_shot.gif)

# Usage

For 💤[Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    {
        "Sologala/cmp-en-hint"
    },
    {
        'hrsh7th/nvim-cmp',
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                sources = cmp.config.sources({
                    { name = 'en_hint', }
                })
            })
        end,
    },
}
```

# Dict source
[google-10000-words](https://github.com/first20hours/google-10000-english/blob/master/google-10000-english-usa.txt)

