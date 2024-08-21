output "repo_url" {
  value       = gitlab_project.project.web_url
  description = "gitlab project url"
}

output "path" {
  value = gitlab_project.project.path_with_namespace
}
