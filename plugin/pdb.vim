augroup pdb
    autocmd!
    autocmd BufRead *.py call pdb#breakpoints#buf_read()
    autocmd BufWrite *.py call pdb#breakpoints#buf_write()
augroup END
