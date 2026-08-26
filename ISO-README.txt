MCO New Age Install v0.9
Packaged by EAO_Lix
Giving back to the community that has given so much

LAST BUNDLED DATE
-----------------
8-21-2026

This ISO package contains the Motor City Online rebuilt installation bundle as
it existed on the last bundled date shown above.

INSTALL
-------
Run:

  Install-MCO-Rebuilt.bat

Default installation folder:

  C:\Program Files (x86)\EA Games\Motor City Online

The installer is designed to run directly from read-only ISO media.

ISO / READ-ONLY MEDIA SUPPORT
-----------------------------
The installer does not attempt to write logs, registry payloads, receipts, or
other runtime files back to the mounted ISO.

Installer and repair logs are written to:

  C:\ProgramData\MCO New Age Install\Logs\

The install receipt is written to:

  C:\ProgramData\MCO-Rebuilt-Installer\install.json

Temporary embedded registry files are written to:

  %TEMP%

After Payload\BaseGame is copied to the selected installation folder, the
installer clears the Read-only attribute recursively from the copied game
files using the actual selected install path.

Equivalent command:

  attrib -R "<InstallDir>\*" /S

Default-path example:

  attrib -R "C:\Program Files (x86)\EA Games\Motor City Online\*" /S

This prevents files copied from read-only ISO media from remaining marked
Read-only after installation.

INSTALLATION CONTENT
--------------------
The rebuilt installer performs the following primary tasks:

  1. Copies the complete, already-updated Motor City Online game folder.

  2. Clears Read-only attributes inherited from ISO media.

  3. Installs and registers the required legacy DAO 3.51 / Jet 3.5 database
     runtime components.

  4. Applies the captured Motor City Online / EA / 3D Setup registry settings.

  5. Applies the NovaServ connection settings.

  6. Installs server.crt into:

       Local Computer
       Trusted Root Certification Authorities

  7. Offers an optional choice to always run mco-launcher.exe as
     Administrator. This is disabled by default. Windows 7 compatibility
     mode is not enabled.

  8. Creates Motor City Online Desktop and Start Menu shortcuts pointing to:

       mco-launcher.exe

  9. Uses mcity.ico for the installed Motor City Online shortcuts.

WIDESCREEN / MOVIE SKIP
-----------------------
The optional Widescreen Hack / Movie Skip is NOT installed automatically.

At the end of installation, the installer displays a reminder that the
optional files are available in:

  Payload\Optional

FIRST-RUN FLOW
--------------
After the core installation is complete:

  Installation completes
          |
          v
  Widescreen / Movie Skip reminder
          |
          v
  3DSetup.exe opens as Administrator
          |
          v
  Installer waits for 3D Setup to close
          |
          v
  mco-launcher.exe starts automatically

The normal Desktop and Start Menu shortcuts continue to launch
mco-launcher.exe for future use.

ISO ICON
--------
The package root contains:

  mcity.ico
  autorun.inf

These identify the ISO as "MCO New Age Install" where supported by Windows.

Windows batch files cannot embed an ICO directly, so the raw .bat files may
still display the normal Windows batch-file icon in Explorer. The installed
Motor City Online shortcuts use mcity.ico.

REPAIR
------
For an already-installed copy of Motor City Online that only needs the legacy
database components repaired, run:

  Repair-MCO-Database.bat

UNINSTALL
---------
Run:

  Uninstall-MCO-Rebuilt.bat

The uninstaller removes the MCO-specific installation, shortcuts, compatibility
entries, NovaServ registry settings, and installed certificate where
appropriate.

Shared DAO / Jet components are intentionally left installed to avoid breaking
other legacy applications that may rely on them.

PACKAGE NOTES
-------------
This rebuild intentionally avoids running the original Motor City Online
InstallShield/setup executable and other ancient installer executables.

The BaseGame payload is expected to contain the already-installed and
already-updated Motor City Online game files.

Last bundled date:

  8-21-2026
