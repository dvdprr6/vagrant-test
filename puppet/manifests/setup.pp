Exec { path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/" ]}

$base_path = '/usr/local/bin/:/usr/local/:/usr/bin/:/bin/'

#
#	System related libs
#
class system_update{
  exec{'yum update':
    command => 'yum update -y',
    timeout => 0
  }
  $sysPackages = [
    "curl",
    "python-pip",
    "sqlite-devel",
    "sqlite",
    "python-devel"
  ]
  package {$sysPackages:
    ensure => "installed",
    require => Exec['yum update']
  }
}

#
# Python 3.3.5
#
class python{
  exec{ "download-python3.3.5":
    command => "wget http://www.python.org/ftp/python/3.3.5/Python-3.3.5.tar.xz",
    cwd => '/home/vagrant',
    creates => '/home/vagrant/Python-3.3.5.tar.xz',
    user => vagrant,
    timeout => 0
  } ->
  exec{"untar-python":
    command => "tar xJf Python-3.3.5.tar.xz",
    cwd => '/home/vagrant',
    creates => '/home/vagrant/Python-3.3.5',
    user => vagrant
  } ->
  exec{"configure-python":
    command => "sh configure --prefix=/opt/python3.3",
    cwd => '/home/vagrant/Python-3.3.5',
    user => vagrant
  } ->
  exec{ "install-python":
    command => "make && make install",
    cwd => '/home/vagrant/Python-3.3.5',
    user => root
  } ->
  # create a directory
  file{"/home/vagrant/bin":
    ensure => "directory"
  } ->
  # set up symlink
  #
  # It is worth to mention that the title (in this example /home/vagrant/bin/py)
  # is the name of the link to create and the filename given in ensure is the
  # file to link to
  #
  file{"/home/vagrant/bin/py":
    ensure => 'link',
    target => '/opt/python3.3/bin/python3.3'
  } ->
  exec{"download-setuptools-deps":
    command => "wget http://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz",
    cwd => '/home/vagrant',
    creates => '/home/vagrant/distribute-0.6.49.tar.gz',
    user => vagrant,
    timeout => 0
  } ->
  exec{"untar-setuptools":
    command => "tar -xzvf distribute-0.6.49.tar.gz",
    cwd => '/home/vagrant',
    creates => '/home/vagrant/distribute-0.6.49',
    user => vagrant
  } ->
  exec{"install-setuptools":
    command => "/home/vagrant/bin/py setup.py install",
    cwd => '/home/vagrant/distribute-0.6.49',
    user => root
  }
}

#
# Maven
#
class maven {
  exec { "download-maven":
    #command => "cp /home/vagrant/downloads/apache-maven-3.2.2-bin.tar.gz /home/vagrant",
    command => "curl -v http://www.dsgnwrld.com/am/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz > apache-maven-3.2.2-bin.tar.gz",
    cwd => '/home/vagrant',
    creates => '/home/vagrant/apache-maven-3.2.2-bin.tar.gz',
    path => $base_path,
    require => Package['curl'],
    user => vagrant,
    timeout => 0
  } ->
  exec { "gunzip-maven": 
    command => "gunzip -c apache-maven-3.2.2-bin.tar.gz | tar xvf -",
    cwd => '/home/vagrant',
    creates => '/home/vagrant/apache-maven-3.2.2',
    user => vagrant
  } ->
  file { "/usr/bin/mvn":
    ensure => link,
    target => "/home/vagrant/apache-maven-3.2.2/bin/mvn"
  }
}

#
#
# Dev Env Init
#
#
class init_dev_env{
  
  include system_update
  include python
  include maven

  Class[system_update]
  ->Class[python]
  ->Class[maven]
}

include init_dev_env