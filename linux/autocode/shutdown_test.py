#!/usr/bin/python
# -*- coding: utf-8 -*-
import gi, sys
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GObject
import datetime

class ShutdownTest(Gtk.Window):

    def __init__(self):
        self.DEFAULT_SHUTDOWN_TIME_SECONDS = 15
        if len(sys.argv) > 1:
            self.DEFAULT_SHUTDOWN_TIME_SECONDS = int(sys.argv[1])

        self.TIMEOUT = 1000

        Gtk.Window.__init__(self, title='Autocode Shutdown Check')
        Gtk.Window.set_position(self, Gtk.WindowPosition.CENTER)
        self.set_border_width(10)

        hbox = Gtk.Box(spacing=10, orientation=Gtk.Orientation.VERTICAL)
        hbox.set_homogeneous(False)

        label = Gtk.Label('Autocode has completed execution. Do you want to shutdown the computer now?')
        label.set_line_wrap(True)
        label.set_justify(Gtk.Justification.FILL)
        hbox.pack_start(label, True, True, 0)

        self.time = self.DEFAULT_SHUTDOWN_TIME_SECONDS
        self.lblCountdown = Gtk.Label(self.generate_countdown_string())
        self.lblCountdown.set_line_wrap(True)
        self.lblCountdown.set_justify(Gtk.Justification.FILL)
        hbox.pack_start(self.lblCountdown, True, True, 0)

        btn_box = Gtk.Box(spacing=10)
        button = Gtk.Button.new_with_label('Shutdown Computer')
        button.connect('clicked', self.on_shutdown_clicked)
        btn_box.pack_start(button, True, True, 0)

        button = Gtk.Button.new_with_label('Cancel Shutdown')
        button.connect('clicked', self.on_cancel_shutdown_clicked)
        btn_box.pack_start(button, True, True, 0)

        hbox.pack_start(btn_box, False, False, 0)

        self.add(hbox)
        self.set_keep_above(True)

    @staticmethod
    def on_shutdown_clicked(button):
        print('Shutdown was requested')
        exit(0)

    @staticmethod
    def on_cancel_shutdown_clicked(button):
        print('Cancel Shutdown was requested')
        exit(1)

    def update_countdown(self):
        self.time = self.time - (self.TIMEOUT/1000)
        self.lblCountdown.set_label(self.generate_countdown_string())
        if self.time <= 0:
            exit(0)
        return True

    # Initialize Timer
    def start_clock_timer(self):
        #  this takes 2 args: (how often to update in milliseconds, the method to run)
        GObject.timeout_add(self.TIMEOUT, self.update_countdown)

    def generate_countdown_string(self):
        return 'If no option is selected Autocode will automatically shutdown the system in %s...' % str(datetime.timedelta(seconds=self.time))

window = ShutdownTest()
window.connect('delete-event', Gtk.main_quit)
window.show_all()
window.start_clock_timer()
Gtk.main()
