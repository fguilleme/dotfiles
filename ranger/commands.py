# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import *

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

# You can import any python module as needed.
import os

# Any class that is a subclass of "Command" will be integrated into ranger as a
# command.  Try typing ":my_edit<ENTER>" in ranger!


class my_edit(Command):
    # The so-called doc-string of the class will be visible in the built-in
    # help that is accessible by typing "?c" inside ranger.
    """:my_edit <filename>

    A sample command for demonstration purposes that opens a file in an editor.
    """

    # The execute method is called when you run this command in ranger.
    def execute(self):
        # self.arg(1) is the first (space-separated) argument to the function.
        # This way you can write ":my_edit somefilename<ENTER>".
        if self.arg(1):
            # self.rest(1) contains self.arg(1) and everything that follows
            target_filename = self.rest(1)
        else:
            # self.fm is a ranger.core.filemanager.FileManager object and gives
            # you access to internals of ranger.
            # self.fm.thisfile is a ranger.container.file.File object and is a
            # reference to the currently selected file.
            target_filename = self.fm.thisfile.path

        # This is a generic function to print text in ranger.
        self.fm.notify("Let's edit the file " + target_filename + "!")

        # Using bad=True in fm.notify allows you to print error messages:
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return

        # This executes a function from ranger.core.acitons, a module with a
        # variety of subroutines that can help you construct commands.
        # Check out the source, or run "pydoc ranger.core.actions" for a list.
        self.fm.edit_file(target_filename)

    # The tab method is called when you press tab, and should return a list of
    # suggestions that the user will tab through.
    # tabnum is 1 for <TAB> and -1 for <S-TAB> by default
    def tab(self, tabnum):
        # This is a generic tab-completion function that iterates through the
        # content of the current directory.
        return self._tab_directory_content()

import re

class ag(Command):
    """:ag 'regex'
    Looks for a string in all marked paths or current dir
    """
    editor = os.getenv('EDITOR') or 'vim'
    acmd = 'ag --smart-case --group --color --hidden'  # --search-zip
    qarg = re.compile(r"""^(".*"|'.*')$""")
    patterns = []
    # THINK:USE: set_clipboard on each direct ':ag' search? So I could find in vim easily

    def _sel(self):
        d = self.fm.thisdir
        if d.marked_items:
            return [f.relative_path for f in d.marked_items]
        # WARN: permanently hidden files like .* are searched anyways
        #   << BUG: files skipped in .agignore are grep'ed being added on cmdline
        if d.temporary_filter and d.files_all and (len(d.files_all) != len(d.files)):
            return [f.relative_path for f in d.files]
        return []

    def _arg(self, i=1):
        if self.rest(i):
            ag.patterns.append(self.rest(i))
        return ag.patterns[-1] if ag.patterns else ''

    def _quot(self, patt):
        return patt if ag.qarg.match(patt) else shell_quote(patt)

    def _bare(self, patt):
        return patt[1:-1] if ag.qarg.match(patt) else patt

    def _aug_vim(self, iarg, comm='Ag'):
        if self.arg(iarg) == '-Q':
            self.shift()
            comm = 'sil AgSet def.e.literal 1|' + comm
        # patt = self._quot(self._arg(iarg))
        patt = self._arg(iarg)  # No need to quote in new ag.vim
        # FIXME:(add support)  'AgPaths' + self._sel()
        cmd = ' '.join([comm, patt])
        cmdl = [ag.editor, '-c', cmd, '-c', 'only']
        return (cmdl, '')

    def _aug_sh(self, iarg, flags=[]):
        cmdl = ag.acmd.split() + flags
        if iarg == 1:
            import shlex
            cmdl += shlex.split(self.rest(iarg))
        else:
            # NOTE: only allowed switches
            opt = self.arg(iarg)
            while opt in ['-Q', '-w']:
                self.shift()
                cmdl.append(opt)
                opt = self.arg(iarg)
            # TODO: save -Q/-w into ag.patterns =NEED rewrite plugin to join _aug*()
            patt = self._bare(self._arg(iarg))  # THINK? use shlex.split() also/instead
            cmdl.append(patt)
        if '-g' not in flags:
            cmdl += self._sel()
        return (cmdl, '-p')

    def _choose(self):
        if self.arg(1) == '-v':
            return self._aug_vim(2, 'Ag')
        elif self.arg(1) == '-g':
            return self._aug_vim(2, 'sil AgView grp|Ag')
        elif self.arg(1) == '-l':
            return self._aug_sh(2, ['--files-with-matches', '--count'])
        elif self.arg(1) == '-p':  # paths
            return self._aug_sh(2, ['-g'])
        elif self.arg(1) == '-f':
            return self._aug_sh(2)
        elif self.arg(1) == '-r':
            return self._aug_sh(2, ['--files-with-matches'])
        else:
            return self._aug_sh(1)

    def _catch(self, cmd):
        from subprocess import check_output, CalledProcessError
        try:
            out = check_output(cmd)
        except CalledProcessError:
            return None
        else:
            return out[:-1].decode('utf-8').splitlines()

    # DEV
    # NOTE: regex becomes very big for big dirs
    # BAD: flat ignores 'filter' for nested dirs
    def _filter(self, lst, thisdir):
        # filter /^rel_dir/ on lst
        # get leftmost path elements
        # make regex '^' + '|'.join(re.escape(nm)) + '$'
        thisdir.temporary_filter = re.compile(file_with_matches)
        thisdir.refilter()

        for f in thisdir.files_all:
            if f.is_directory:
                # DEV: each time filter-out one level of files from lst
                self._filter(lst, f)

    def execute(self):
        cmd, flags = self._choose()
        # self.fm.notify(cmd)
        # TODO:ENH: cmd may be [..] -- no need to shell_escape
        if self.arg(1) != '-r':
            self.fm.execute_command(cmd, flags=flags)
        else:
            self._filter(self._catch(cmd))

    def tab(self):
        # BAD:(:ag <prev_patt>) when input alias ':agv' and then <Tab>
        #   <= EXPL: aliases expanded before parsing cmdline
        cmd = self.arg(0)
        flg = self.arg(1)
        if flg[0] == '-' and flg[1] in 'flvgprw':
            cmd += ' ' + flg
        return ['{} {}'.format(cmd, p) for p in reversed(ag.patterns)]
