terraform {
  backend "remote" {
    organization = "arka111-io"

    workspaces {
      name = "arka111"
    }
  }
}