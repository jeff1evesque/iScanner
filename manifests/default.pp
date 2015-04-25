# git: install git if not 'present'.
class git {
    package {'git':
        ensure => present,
    }
}

# gnome ui: install gnome-ui if not 'present'.
class gnome {
    $gnome_packages = ['xorg', 'gnome-core', 'gnome-system-tools', 'gnome-app-install']
    package {$gnome_packages:
        ensure => present,
    }
}

# implement classes
include git
include gnome