package Pod::Weaver::Section::BashCompletion::GetoptLongComplete;

our $DATE = '2014-11-12'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use Moose;
with 'Pod::Weaver::Role::Section';

use List::Util qw(first);
use Moose::Autobox;

sub weave_section {
    my ($self, $document, $input) = @_;

    my $filename = $input->{filename} || 'file';

    my $command_name;
    if ($filename =~ m!^(bin|script)/(.+)$!) {
        $command_name = $2;
    } else {
        $self->log_debug(["skipped file %s (not an executable)", $filename]);
        return;
    }

    # find file content in zilla object, not directly in filesystem, because the
    # file might be generated dynamically by dzil.
    my $file = first { $_->name eq $filename } @{ $input->{zilla}->files };
    unless ($file) {
        $self->log_fatal(["can't find file %s in zilla object", $filename]);
    }
    my $content = $file->content;
    #unless ($content =~ /\A#!.+perl/) {
    #    $self->log_debug(["skipped file %s (not a Perl script)",
    #                      $filename]);
    #    return;
    #}
    unless ($content =~ /(use|require)\s+Getopt::Long::Complete\b/) {
        $self->log_debug(["skipped file %s (does not use Getopt::Long::Complete)",
                          $filename]);
        return;
    }

    my $text = <<_;
This script has bash completion capability.

To activate bash completion for this script, put:

 complete -C $command_name $command_name

in your bash startup (e.g. C<~/.bashrc>). Your next shell session will then
recognize tab completion for the command. Or, you can also directly execute the
line above in your shell to activate immediately.

You can also install L<App::BashCompletionProg> which makes it easy to add
completion for Getopt::Long::Complete-based scripts. After you install the
module and put C<. ~/.bash-complete-prog> (or C<. /etc/bash-complete-prog>), you
can just run C<bash-completion-prog> and the C<complete> command will be added
to your C<~/.bash-completion-prog>. Your next shell session will then recognize
tab completion for the command.

_

    $document->children->push(
        Pod::Elemental::Element::Nested->new({
            command  => 'head1',
            content  => 'BASH COMPLETION',
            children => [
                map { s/\n/ /g; Pod::Elemental::Element::Pod5::Ordinary->new({ content => $_ })} split /\n\n/, $text
            ],
        }),
    );
}

no Moose;
1;
# ABSTRACT: Add a BASH COMPLETION section for Getopt::Long::Complete-based scripts

__END__

=pod

=encoding UTF-8

=head1 NAME

Pod::Weaver::Section::BashCompletion::GetoptLongComplete - Add a BASH COMPLETION section for Getopt::Long::Complete-based scripts

=head1 VERSION

This document describes version 0.01 of Pod::Weaver::Section::BashCompletion::GetoptLongComplete (from Perl distribution Pod-Weaver-Section-BashCompletion-GetoptLongComplete), released on 2014-11-12.

=head1 SYNOPSIS

In your C<weaver.ini>:

 [BashCompletion::GetoptLongComplete]

=head1 DESCRIPTION

This section plugin adds a BASH COMPLETION section for
Getopt::Long::Complete-based scripts. The section contains information on how to
activate bash completion for the scripts.

=for Pod::Coverage weave_section

=head1 SEE ALSO

L<Getopt::Long::Complete>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Pod-Weaver-Section-BashCompletion-GetoptLongComplete>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Pod-Weaver-Section-BashCompletion-GetoptLongComplete>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Pod-Weaver-Section-BashCompletion-GetoptLongComplete>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
