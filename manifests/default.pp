## git: install git if not 'present'.
package {'git':
    ensure => present,
}

## git-opencv: install opencv from github repository.
#
#  @path, the qualified path for the supplied command.
#
#  @require, defines depedencies for given command.
#
#  @timeout, the maximum time (seconds) the supplied command is allowed to
#      run. By default, this attribute is set to 300.
exec {'git-opencv':
    command => 'git clone https://github.com/Itseez/opencv.git',
    require => Package['git'],
    path => '/usr/bin',
    timeout => 450,
}
