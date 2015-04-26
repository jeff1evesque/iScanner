## variables
$opencv_directory = '/home/vagrant'

## git: install git if not 'present'.
package {'git':
    ensure => present,
}

## directory: create 'opencv' directory
file {"${opencv_directory}/OpenCV":
    ensure => 'directory',
}

## git-opencv: install opencv from github repository. However, if the target
#              clone path already exists, then successive 'git clone'
#              commands will not succeed.
#
#  @require, defines depedencies for given command.
#
#  @cwd, change the current working directory.
#
#  @path, the qualified path for the supplied command.
#
#  @timeout, the maximum time (seconds) the supplied command is allowed to
#      run. By default, this attribute is set to 300.
exec {'git-opencv':
    command => 'git clone https://github.com/Itseez/opencv.git opencv/',
    require => [Package['git'], File["${opencv_directory}/opencv"]],
    cwd     => "${opencv_directory}/OpenCV",
    path    => '/usr/bin',
    timeout => 450,
    notify  => Exec['cmake-opencv'],
}

## directory: create 'release' directory
file {"${opencv_directory}/OpenCV/opencv/release":
    ensure => 'directory',
}

## cmake-opencv: build opencv
#
#  @refreshonly, when set to true, the corresponding exec will only run when
#      it receives an event. Refresh events can be sent via notify, subscribe,
#      or ~>.  In this case, 'git-opencv' implements the needed notify event.
exec {'cmake-opencv':
    command     => 'cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..'
    cwd         => "${opencv_directory}/OpenCV/opencv/release",
    refreshonly => true,
}
