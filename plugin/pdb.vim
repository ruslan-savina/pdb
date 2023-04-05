augroup pdb
    autocmd!
    autocmd BufRead *.py call pdb#breakpoints#buf_read()
    autocmd BufWrite *.py call pdb#breakpoints#buf_write()
    autocmd InsertEnter * call pdb#breakpoints#insert_enter()
    autocmd TextChangedI * call pdb#breakpoints#text_changed_i()
    autocmd TextYankPost * call pdb#breakpoints#text_yank_post(v:event)
augroup END
