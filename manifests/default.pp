# git: install git if not 'present'.
class git {
    package {'git':
        ensure => present,
    }
}

# gnome ui: install gnome-ui if not 'present' (double quote needed).
class gnome {
    $gnome_packages = ["xorg", "gnome-core", "gnome-system-tools", "gnome-app-install"]
    package {$gnome_packages:
        ensure => present,
    }
}

# gcc: installs the c++ compiler if not 'present'
class gcc {
    package {'g++':
        ensure => present,
    }
}

# implement classes
include git
include gnome
include gcc