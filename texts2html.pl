#!/usr/bin/env perl
package Texts2Html;
use Mojo::Base -base, -signatures;
use Mojo::Util qw(decode encode getopt dumper);
use Mojo::File qw(path);
use Mojo::Collection qw(c);

BEGIN {
    binmode STDOUT => ':utf8';
    binmode STDERR => ':utf8';
}

no warnings 'redefine';
local *Data::Dumper::qquote  = sub {qq["${\(shift)}"]};
local $Data::Dumper::Useperl = 1;
has title     => 'За буквите на различни словѣнски наречия';
has texts     => sub { c() };
has languages => sub { c() };
has endnotes  => sub { c() };
has last_row  => 30;

# Buttons for showing hiding columns. The functionality is attached to them by
# o-pismeneh.js during loading of the page.
has buttons => sub { c() };

# After which column the columns must be collapsed?
has collapse_after => 2;

sub make_rows($self) {
    my $matrix = $self->texts->map(
        sub($f) {
            return [split /\r?\n/, decode utf8 => path($f)->slurp];
        }
    );

    #the first language is the leading so we count where it ends
    my $last_row = $self->last_row;
    my $columns  = int @$matrix / 12;
    my $after    = $self->collapse_after;
    my $exlapse  = 'expand';
    $matrix->each(
        sub ($txt, $num) {
            my $lang  = $self->languages->[$num - 1];
            my $count = 0;
            if ($num <= $after) {

                # Class to be applied to the columns depending on after which
                # column the rest should be collapsed initially.
                # $exlapse = 'expand';
                push @{$self->buttons},
                  qq|<button class="button primary" for="$lang$num">$num ($lang)</button>|;
            }
            else {
                # $exlapse = 'collapse';
                push @{$self->buttons},
                  qq|<button class="button" for="$lang$num">$num ($lang)</button>|;
            }
            foreach my $r (0 .. @$txt - 1) {
                last if $count == $last_row;
                $count++;
                next if $txt->[$r] =~ /^\s*?$/;
                next if $txt->[$r] =~ /^#/;

                # link to endnote
                $txt->[$r]
                  =~ s|\[(\d+)\]|<sup><a id="l_${num}_$1" href="#n_${num}_$1">$1</a></sup>|gx;

                # wrap with html
                # Each language goes to its own column.
                if ($r > 0) {
                    $txt->[$r] = <<~"TXT";
                <td lang="$lang" class="$exlapse $lang$num">
                    <p class="$exlapse">$txt->[$r]</p>
                </td>
                TXT
                }
                else {
                    $txt->[$r] = <<~"TXT";
                <th lang="$lang" class="$exlapse $lang$num">
                    <p class="$exlapse">
                    <button class="button icon-only exlapse $lang$num" title="сгъни/разгъни">↭</button>
                    <button class="button icon-only to-left $lang$num" title="премести наляво">⮄</button>
                    <button class="button icon-only to-right $lang$num" title="премести надясно">⮆</button><br>
                    <select lang="$lang" class="$lang$num">
                        <option value=""></option>
                        <option value="normal">Veleka</option>
                        <option value="cu">Bukyvede</option>
                    </select>
                    </p>
                    <h3 class="$exlapse">$num ($lang) $txt->[$r]</h3>
                </th>
                TXT
                }
            }

            # Prepare all end-notes as one table row
            my @endnotes = @$txt[$last_row .. @$txt - 1];
            my $endnotes =
              c(@endnotes)->map(sub { $_ =~ /Bele|Беле|Приме|Pozn/ ? () : $_ })
              ->compact->join(qq|</p><p class="$exlapse">|);
            $endnotes = qq|<p class="$exlapse">$endnotes</p>|;
            $endnotes
              =~ s|(\d+)\.\s|<a id="n_${num}_$1" href="#l_${num}_$1">$1. ↑</a> |gmsx;

            push @{$self->endnotes},
              qq|<td lang="$lang" class="$exlapse $lang$num">$endnotes</td>|;
            return;
        }
    );

#    # column widths
#    my $col_width = int 100 / @$matrix;
#    $matrix->each(
#        sub ($txt, $num) {
#        unshift @$txt, qq|<col width="$col_width" />|;
#    });
    my @rows = ();
    my $c    = 0;
    for my $r (0 .. $last_row) {
        next unless $matrix->[0][$r];
        $rows[$c] = '';
        for my $col (0 .. @$matrix - 1) {
            $rows[$c] .= $matrix->[$col][$r];
        }
        $rows[$c] = qq|<tr>$/$rows[$c]$/</tr>|;

        # warn $rows[$c];
        # sleep 1;
        $c++;
    }

    # add endnotes as last row of the big table
    push @rows, '<tr>' . $/ . $self->endnotes->join($/) . $/ . '</tr>';
    return c(@rows);
}


# Prepares html from collected ednotes.
# Obsolete
sub endnotes_html($self) {
    return qq|<div class="row">$/${\$self->endnotes->join("\n")}$/</div>|;
}

sub make_html($self) {
    my $all = $self->make_rows;
    return <<~"HTML";
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://слово.бг/css/malka/chota_all_min.css">
    <link rel="stylesheet" href="https://слово.бг/css/fonts.css">
    <script src="https://слово.бг/mojo/jquery/jquery.js"></script>
    <title>${\ $self->title }…</title>
  </head>
  <body>
<header class="is-fixed bg-dark row">
  <h2 id="txt">${\ $self->title }</h2>
</header>

  <style>
    main.container {
        max-width:90%;
    }
    table#xapli th,
    table#xapli td {
      vertical-align:top;
      max-height:35rem;
      -moz-user-select: none;
      -webkit-user-select: none;
      -ms-user-select: none;
      user-select: none;
    }
    table#xapli button {
      padding: 0.5rem 1rem;
      border-radius: 4px;
    }
    .exlapse .mv-left, .mv-right {
      font-size:2rem;
    }
    .expand {
      min-width: 20rem;
      overflow: auto;
    }
    .collapse {
      width: 2.1em;
      height: 2.3em;
      text-overflow: ellipsis;
      overflow: hidden;
    }
    .cu {
    /* font-family: BukyvedeRegular;*/
      font-family: Bukyvede;
    }
    .normal {
      font-family: Veleka;
    }
  </style>
  <h2 id="txt">${\ $self->title }</h2>
  <table id="xapli">
    <caption id="column_buttons">${\$self->buttons->join()}</caption>
  ${\ $all->join($/) }
  </table>
  <script src="o-pismeneh.js"></script>
  </body>
</html>
HTML

#  <fieldset><legend>БЕЛЕЖКИ</legend>
#  <a href="#txt" style="float:right" title=Към началѿо">↑</a>
#  ${\ $self->endnotes_html }
#  </fieldset>
}

sub run ($self, @args) {
    getopt \@args,
      't|texts=s@'         => \(my $texts     = []),
      'l|languages=s@'     => \(my $languages = []),
      'r|last_row=i'       => \(my $last_row  = $self->last_row),
      'title=s'            => \(my $title     = $self->title),
      'c|collapse_after=i' => \(my $after     = $self->collapse_after);
    @$texts or die 'Nothing to do! Please provide text files via --texts or -t!';
    @$languages
      or die
      'PLease provide the same number of languages as text files via --languages or -l!';
    $texts     = [split /,\s*?/, join(',', @$texts)];
    $languages = [split /,\s*?/, join(',', @$languages)];
    @$texts == @$languages or die 'Text files and languages must have equal length!';
    STDERR->say("Last row to be processed is $last_row. Default: ${\$self->last_row}.");

    # sleep 1;
    return $self->last_row($last_row)->title($title)->texts(c(@$texts))
      ->collapse_after($after)->languages(c(@$languages))->make_html();
}


sub main {
    say __PACKAGE__->new()->run(@ARGV);
}


main() if not caller();
1;

=encoding utf8

=head1 NAME

Texts2Html - put texts in different languages together side by side for displaying on the web.

=head1 SYNOPSIS

  texts2html.pl --texts='file1.txt,file2.txt,file3.txt' -l 'uc,bg,ru'

  ./texts2html.pl \
    -t 'o-pismeneh-cu.txt,o-pisneneh-cu-1348.txt,o-pismeneh-bg-1944.txt,o-pismeneh-bg.txt,o-pismeneh-bg-nw.txt,o-pismeneh-mk.txt' \
    -l 'cu,cu,bg,bg,bg,mk' \
    -t 'o-pismeneh-cu1.txt,o-pismenah-ru.txt,o-pismenah-ru1.txt,o-pismenima-sr.txt,o-pismenech-cs.txt' \
    -l 'cu,ru,ru,sr,cs' \
    -t 'o-pismenech-cs2bg.txt,o-pismeneh-bg2cz.txt,o-pismeneh-uk.txt' \
    -l 'cs,bg,uk' \
    -c 3 -r 31 > o-pismeneh-all.html

=head1 DESCRIPTION

Gets two (or more) text files and puts them together in diple,triple... hexaple
to comapare them in HTML. Returns the output on the STDOUT. You can redirect it
to a file your self.

=cut
