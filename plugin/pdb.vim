augroup pdb
    autocmd!
    autocmd BufRead *.py call pdb#breakpoints#load()
    autocmd BufWrite *.py call pdb#breakpoints#save()
augroup END
