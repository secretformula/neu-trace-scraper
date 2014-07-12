gruntFunction = (grunt) ->
  grunt.initConfig
    copy:
      'build':
        cwd: 'src'
        src: ['**', '!**/*.coffee']
        dest: 'dist'
        expand: true
    clean:
      'clean':
        src: ['dist', 'dist/**/*.js']
    coffee:
      'build':
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: 'src'
          src: ['**/*.coffee']
          dest: 'dist'
          ext: '.js'
        ]
    coffeelint:
      options:
        'max_line_length':
          level: 'ignore'
      'build': ['src/**/*.coffee']
    watch:
      files: ['src/*']
      tasks: ['build']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'


  grunt.registerTask(
    'build',
    'Compiles all assets and copies to build directory in a format relevant for development',
    [
      'clean'
      'coffeelint:build'
      'copy:build'
      'coffee:build'
    ]
  )

module.exports = gruntFunction
