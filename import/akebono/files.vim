vim9script noclear

var cache: list<dict<any>> = []

def Items(refresh: bool): list<dict<any>>
  if empty(cache) || refresh
    cache = Files(readdir(getcwd()))->mapnew((_, f) => ({ word: f }))
  endif
  return cache
enddef

def Files(dirs: list<string>): list<string>
  var entries: list<string> = []
  var dirfiles: list<string> = []
  for e in dirs
    if fnamemodify(e, ':t') =~# '\.git'
      continue
    endif
    var ftype = getftype(e)
    if ftype ==# 'dir'
      dirfiles += readdir(e)->mapnew((_, f) => $"{e}/{f}")->Files()
    else
      add(entries, e)
    endif
  endfor
  entries += dirfiles
  return entries
enddef

def Accept(context: dict<any>, item: dict<any>): void
  win_execute(context.winid, $"edit {item.word}")
enddef

export def Export(): dict<any>
  return {
    Items: Items,
    Accept: Accept,
  }
enddef
