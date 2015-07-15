'use strict';

var gulp   = require('gulp');
var plugins = require('gulp-load-plugins')();
var del = require('del');

var CI = process.env.CI === 'true';

require('coffee-script/register')

var paths = {
  coffee: ['./lib/**/*.coffee'],
  watch: ['./gulpfile.js', './lib/**', './spec/**', '!spec/{temp,temp/**}'],
  tests: ['./spec/**/*.coffee', '!spec/{temp,temp/**}']
};

var plumberConf = {};

if (process.env.CI) {
  plumberConf.errorHandler = function(err) {
    throw err;
  };
}

gulp.task('lint', function () {
  return gulp.src(paths.coffee)
    .pipe(plugins.coffeelint())
    .pipe(plugins.coffeelint.reporter());
});

gulp.task('test', function (cb) {
  return gulp.src(paths.tests, {read: false})
    .pipe(plugins.plumber(plumberConf))
    .pipe(plugins.mocha({
      reporter: CI ? 'spec' : 'nyan',
      timeout: '5s',
      globals: {
        should: require('should')
      }
    }));
});

gulp.task('bump', ['test'], function () {
  var bumpType = plugins.util.env.type || 'patch'; // major.minor.patch

  return gulp.src(['./package.json'])
    .pipe(plugins.bump({ type: bumpType }))
    .pipe(gulp.dest('./'));
});

gulp.task('watch', ['test'], function () {
  gulp.watch(paths.watch, ['test']);
});

gulp.task('release', ['bump']);

gulp.task('clean', function(cb) {
  del(['dist/**/*'], cb);
});

gulp.task('dist', ['clean'], function () {
  return gulp.src(paths.coffee, {base: './lib'})
    .pipe(plugins.coffee({bare: true})).on('error', plugins.util.log)
    .pipe(gulp.dest('./dist'));
});

gulp.task('default', ['lint', 'test', 'dist']);
