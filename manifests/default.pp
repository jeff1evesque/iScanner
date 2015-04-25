# git: install git if not 'present'.
class git {
    package {'git':
        ensure => present,
    }
}

# implement classes
include git
