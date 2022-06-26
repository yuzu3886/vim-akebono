vim9script noclear

var context: dict<any>

var source: dict<any>
var restcmd: string
var ui: dict<any>
var items: list<any>
var filterdItems: list<any>

export def Open(ex: dict<any>): void
  source = ex
  context = {
    winid: win_getid(),
    input: '',
  }
  ui = { winrestcmd: winrestcmd() }

  InitBuffer()
  InitFilterBuffer()
  redraw

  GetItems(false)
  Filter(true)
enddef

def GetItems(refresh: bool): void
  items = source.Items(refresh)
enddef

def InitBuffer(): void
  execute('keepalt botright :10new akebono')
  ui.bufnr = bufnr('%')
  ui.winid = win_getid()
  SetOptions()
  setlocal cursorline
enddef

def InitFilterBuffer(): void
  execute('keepalt botright :1new akebono-filter')
  ui.filterBufnr = bufnr('%')
  ui.filterWinid = win_getid()
  SetOptions()
  augroup _akebono_
    autocmd!
    autocmd TextChangedI,TextChangedP,TextChanged <buffer> Filter(false)
  augroup END
  inoremap <buffer><CR>  <ScriptCmd>Accept()<CR>
  inoremap <buffer><ESC> <ScriptCmd>Quit()<CR>
  inoremap <buffer><F5>  <ScriptCmd>Refresh()<CR>
  inoremap <buffer><C-j> <ScriptCmd>Down()<CR>
  inoremap <buffer><C-k> <ScriptCmd>Up()<CR>
  startinsert!
enddef

def SetOptions(): void
  setlocal bufhidden=unload
  setlocal buftype=nofile
  setlocal nobuflisted
  setlocal noswapfile
  setlocal colorcolumn=
  setlocal nolist
  setlocal nonumber
  setlocal norelativenumber
  setlocal nospell
  setlocal nowrap
  setlocal signcolumn=no
  setlocal winfixheight
enddef

def Filter(force: bool): void
  var input: string = getbufline(ui.filterBufnr, 1)[0]
  if !force && context.input ==# input
    return
  endif
  context.input = input

  filterdItems = empty(context.input) ? items[: 999] :
        matchfuzzy(items, context.input, { key: 'word', limit: 1000 })

  Render()
enddef

def Render(): void
  var lines: list<string> = empty(filterdItems) ? [''] : filterdItems->mapnew((_, item) => item.word)

  setbufline(ui.bufnr, 1, lines)
  silent deletebufline(ui.bufnr, len(lines) + 1, '$')

  win_execute(ui.winid, 'keepjumps normal! gg')
enddef

def Accept(): void
  if empty(filterdItems)
    return
  endif
  var i: number = line('.', ui.winid) - 1

  Quit()

  source.Accept(context, filterdItems[i])
enddef

def Quit(): void
  stopinsert
  win_execute(ui.filterWinid, 'close')
  win_execute(ui.winid, 'close')
  win_gotoid(context.winid)
  execute(ui.winrestcmd)
enddef

def Refresh(): void
  GetItems(true)
  Filter(true)
enddef

def Up(): void
  win_execute(ui.winid, 'normal! k')
enddef

def Down(): void
  win_execute(ui.winid, 'normal! j')
enddef
