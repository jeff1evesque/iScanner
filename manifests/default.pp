## variables
$opencv_directory = '/home/vagrant'

## git: install git if not 'present'.
package {'git':
    ensure => present,
}

## directory: create 'opencv' directory
file {"${opencv_directory}/opencv":
    ensure => 'directory',
}

## git-opencv: install opencv from github repository.
#
#  @path, the qualified path for the supplied command.
#
#  @require, defines depedencies for given command.
#
#  @timeout, the maximum time (seconds) the supplied command is allowed to
#      run. By default, this attribute is set to 300.
#
#  Note: if the target clone path already exists, then additional 'git clone'
#        commands will not succeed.
exec {'git-opencv':
    command => 'git clone https://github.com/Itseez/opencv.git opencv/',
    require => [Package['git'], File["${opencv_directory}/opencv"]],
    cwd     => "${opencv_directory}/opencv",
    path => '/usr/bin',
    timeout => 450,
}
