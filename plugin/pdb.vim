let g:pdb_module_name = get(g:, 'pdb_module_name', 'pdb')
let g:pdb_django_settings = get(g:, 'pdb_django_settings', v:null)
let g:pdb_docker_compose_service_name = get(g:, 'pdb_docker_compose_service_name', v:null)
let g:pdb_docker_container_name = get(g:, 'pdb_docker_container_name', pdb#GetDockerContainerName())
