const gulp = require('gulp');
const uglify = require('gulp-uglify');
const htmlmin = require('gulp-htmlmin');
const csso = require('gulp-csso');

gulp.task('minify-js', function() {
  return gulp.src('build/web/**/*.js')
    .pipe(uglify({
      output: {
        comments: false
      }
    }))
    .pipe(gulp.dest('build/web'));
});

gulp.task('minify-html', function() {
  return gulp.src('build/web/**/*.html')
    .pipe(htmlmin({
      collapseWhitespace: true,
      removeComments: true
    }))
    .pipe(gulp.dest('build/web'));
});

gulp.task('minify-css', function() {
  return gulp.src('build/web/**/*.css')
    .pipe(csso({
      comments: false
    }))
    .pipe(gulp.dest('build/web'));
});

gulp.task('default', gulp.parallel('minify-js', 'minify-html', 'minify-css'));
