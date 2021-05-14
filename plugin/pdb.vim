augroup pdb
    autocmd!
    autocmd BufRead FileType python call pdb#breakpoints#load()
    autocmd BufWrite FileType python call pdb#breakpoints#save()
augroup END
