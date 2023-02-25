resource "random_password" "kubefirst_bot" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "gitlab_user" "kubefirst_bot" {
  name     = "Kubefirst Bot"
  username = "kubefirst-bot"
  password = random_password.kubefirst_bot.result
  email    = var.kubefirst_bot_user_email
  is_admin = true
}

resource "gitlab_group_membership" "kubefirst_bot" {
  group_id     = gitlab_group.developers.id
  user_id      = gitub_user.kubefirst_bot.user_id
  access_level = "maintainer"
}

resource "gitlab_user_sshkey" "kubefirst_bot" {
  user_id = gitlab_user.kubefirst_bot.id
  title   = "kubefirst-bot"
  key     = var.kubefirst_bot_ssh_public_key

  depends_on = [gitlab_user.kubefirst_bot, gitlab_group_membership.kubefirst_bot]
}
