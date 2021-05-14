let g:breakpoints_data = {}

augroup pdb_breakpoints
    autocmd!
    autocmd BufRead * call s:buf_read()
    autocmd BufWrite * call s:buf_write()
augroup END

function! s:buf_read()
    let file_name = pdb#common#get_current_file_path()
    call s:place_breakpoint_signs(file_name)
endfunction

function! s:buf_write()
    let file_name = pdb#common#get_current_file_path()
    call s:update_breakpoints_data(file_name)
    call s:save_breakpoints_data()
endfunction

function! s:is_breakpoint_exists(file_name, line_number)
    return !empty(sign_getplaced(
    \   a:file_name, {'group': 'Breakpoint', 'lnum': a:line_number})[0].signs
    \)
endfunction

function! s:place_breakpoint_sign(file_name, line_number)
    if !s:is_breakpoint_exists(a:file_name, a:line_number)
        return sign_place(
        \   0, 'Breakpoint', 'Breakpoint', a:file_name, 
        \   {'lnum': a:line_number, 'priority': 1000}
        \)
    endif
endfunction

function! s:place_breakpoint_signs(file_name)
    for [file_name, line_numbers] in items(g:breakpoints_data)
        if file_name == a:file_name
            for line_number in line_numbers
                call s:place_breakpoint_sign(file_name, line_number)
            endfor
        endif
    endfor
endfunction

function! s:update_breakpoints_data(file_name)
    let line_numbers = []
    let lines_count = line('$')
    for sign_data in s:get_breakpoint_signs(a:file_name)
        if sign_data.lnum <= lines_count
            call add(line_numbers, sign_data.lnum)
        else
            call s:delete_breakpoint_sign(a:file_name, sign_data.lnum)
        endif
    endfor
    if !empty(line_numbers)
        let g:breakpoints_data[a:file_name] = line_numbers
    elseif has_key(g:breakpoints_data, a:file_name)
        call remove(g:breakpoints_data, a:file_name)
    endif
endfunction

function! s:get_breakpoint_signs(file_name)
    return sign_getplaced(a:file_name, {'group': 'Breakpoint'})[0].signs
endfunction

function! s:delete_breakpoint_sign(file_name, line_number)
    let line_number = empty(a:line_number) ? line('.') : a:line_number
    let signs = sign_getplaced(
    \   a:file_name, {'group': 'Breakpoint', 'lnum': line_number}
    \)[0].signs
    if !empty(signs)
        let sign = signs[0]
        call sign_unplace(
        \    'Breakpoint', {'buffer': a:file_name, 'id': sign.id}
        \)
    endif
endfunction

function! s:delete_buffer_breakpoint_signs(file_name)
    call sign_unplace('Breakpoint', {'buffer': a:file_name})
endfunction

function! s:delete_all_breakpoint_signs()
    call sign_unplace('Breakpoint')
endfunction

function! s:save_breakpoints_data()
    call writefile(
    \   [string(g:breakpoints_data)], g:pdb_breakpoints_file_name
    \)
endfun

function! s:load_breakpoints_data()
    if file_readable(g:pdb_breakpoints_file_name)
        let lines = readfile(g:pdb_breakpoints_file_name)
        if !empty(lines)
            execute "let g:breakpoints_data = " . lines[0]
        endif
    endif
endfun

function! s:update_breakpoints_quickfix()
    let items = []
    for [file_name, line_numbers] in items(g:breakpoints_data)
        for line_number in line_numbers
            let item = {
                \ 'filename': fnamemodify(file_name, ':p'),
                \ 'lnum': line_number,
                \ 'text': '',
                \ }
            call add(items, item)
        endfor
    endfor
    call setqflist(items, 'r')
endfunction

function! pdb#breakpoints#add()
    let file_name = pdb#common#get_current_file_path()
    call s:place_breakpoint_sign(file_name, line('.'))
    call s:update_breakpoints_data(file_name)
    call s:update_breakpoints_quickfix()
    call s:save_breakpoints_data()
endfunction

function! pdb#breakpoints#delete()
    let file_name = pdb#common#get_current_file_path()
    call s:delete_breakpoint_sign(file_name, line('.'))
    call s:update_breakpoints_data(file_name)
    call s:update_breakpoints_quickfix()
    call s:save_breakpoints_data()
endfunction

function! pdb#breakpoints#delete_in_buffer()
    let file_name = pdb#common#get_current_file_path()
    call s:delete_buffer_breakpoint_signs(file_name)
    call s:update_breakpoints_data(file_name)
    call s:update_breakpoints_quickfix()
    call s:save_breakpoints_data()
endfunction

function! pdb#breakpoints#delete_all()
    call s:delete_all_breakpoint_signs()
    let g:breakpoints_data = {}
    call s:update_breakpoints_quickfix()
    call s:save_breakpoints_data()
endfunction

function! pdb#breakpoints#list()
    call s:update_breakpoints_quickfix()
    copen
endfunction

call s:load_breakpoints_data()
