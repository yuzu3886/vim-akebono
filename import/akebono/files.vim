vim9script noclear

var cache: list<dict<any>> = []

def Items(refresh: bool): list<dict<any>>
  if empty(cache) || refresh
    cache = systemlist('rg --files --hidden --glob="!.git"')->mapnew((_, f) => ({ word: f }))
  endif
  return cache
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
