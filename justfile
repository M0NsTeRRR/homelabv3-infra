set quiet := true

mod ansible '.justfiles/ansible.just'
mod docs '.justfiles/docs.just'
mod flatcar '.justfiles/flatcar.just'
mod incus '.justfiles/incus.just'
mod kanidm '.justfiles/kanidm.just'
mod kubernetes '.justfiles/kubernetes.just'
mod octodns '.justfiles/octodns.just'

[private]
default:
    just --list --list-submodules
