vim9script

if get(g:, 'loaded_akebono', false)
  finish
endif
g:loaded_akebono = true

import 'akebono.vim'
import 'akebono/files.vim'

command! AkebonoFiles akebono.Open(files.Export())
