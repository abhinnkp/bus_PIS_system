# System Architecture and Flows

This document contains Mermaid diagrams illustrating the key architectural flows of the ABDOS system.

## 1. Overall System Architecture

```mermaid
graph TD
    subgraph "Raspberry Pi Hardware"
        HW[Watchdog Timer]
        NET[Ethernet & Wi-Fi]
        DISP[HDMI Display]
    end

    subgraph "OS Foundation (Pi OS Lite)"
        SYS[systemd]
        NM[NetworkManager]
        PLY[Plymouth Splash]
    end

    subgraph "ABDOS Environment"
        CONF[/boot/firmware/abdos.conf/]
        X11[X Server]
        WM[Openbox WM]
        KIO[Chromium Kiosk]
    end

    SYS -->|Manages| NM
    SYS -->|Manages| PLY
    SYS -->|Manages| X11
    SYS -->|Pings| HW

    CONF -->|Configures| NM
    CONF -->|Configures| KIO

    X11 -->|Renders to| DISP
    X11 -->|Hosts| WM
    WM -->|Manages| KIO
    KIO -->|Uses| NET
```

## 2. Configuration Flow

```mermaid
graph TD
    A[Power On] --> B[systemd initialized]
    B --> C[abdos-config.service runs]
    C --> D{Read /boot/firmware/abdos.conf}
    D --> E[Parse variables]
    E --> F[Generate NetworkManager Profiles]
    E --> G[Export Environment Variables for Kiosk]
    E --> H[Configure Hostname & Timezone]
    F --> I[Network Connection]
    G --> J[Browser Launch with URL]
```

## 3. Boot Sequence

```mermaid
sequenceDiagram
    participant Bootloader
    participant Kernel
    participant Plymouth
    participant systemd
    participant Network
    participant Display

    Bootloader->>Kernel: Load OS (Silent Mode)
    Kernel->>Plymouth: Start custom splash
    Kernel->>systemd: Init processes
    systemd->>Network: Initialize NetworkManager
    Network-->>systemd: network-online.target reached
    systemd->>Display: Start minimal X11 & Openbox
    Display->>Display: Launch Chromium Kiosk
    Display->>Plymouth: Terminate splash (seamless)
```

## 4. Service Dependency

```mermaid
graph TD
    SYS[systemd] --> NM[NetworkManager.service]
    SYS --> PLY[plymouth-start.service]

    SYS --> CFG[abdos-config.service]
    CFG --> NM

    SYS --> KIO[abdos-kiosk.service]
    KIO -.->|Requires| NM_ON[network-online.target]
    NM_ON -.-> NM
    KIO -.->|Requires| CFG

    KIO --> X[Xorg]
    KIO --> OB[Openbox]
    KIO --> CHR[Chromium]

    PLY -.->|Conflicts| KIO_UP[Kiosk Up]
```

## 5. Network Flow

```mermaid
graph TD
    START[Network Start] --> CHECK_ETH{Ethernet Connected?}
    CHECK_ETH -->|Yes| USE_ETH[Use Ethernet Connection]
    CHECK_ETH -->|No| CHECK_WIFI{Wi-Fi Configured & Available?}

    CHECK_WIFI -->|Yes| USE_WIFI[Connect to Wi-Fi]
    CHECK_WIFI -->|No| WAIT[Wait for Connection]

    USE_ETH --> MON_ETH[Monitor Link]
    MON_ETH -->|Link Down| CHECK_WIFI

    USE_WIFI --> MON_WIFI[Monitor Link]
    MON_WIFI -->|Ethernet Plugged In| USE_ETH
    MON_WIFI -->|Wi-Fi Down| WAIT
```

## 6. Browser Lifecycle

```mermaid
stateDiagram-v2
    [*] --> NetworkWait: systemd start
    NetworkWait --> Launching: Network Online
    Launching --> Running: Chromium Started

    Running --> Crashed: Browser Process Exits (Error)
    Crashed --> Launching: systemd Restart=always

    Running --> GracefulExit: System Shutdown
    GracefulExit --> [*]
```

## 7. Watchdog Recovery Flow

```mermaid
graph TD
    A[System Running normally] --> B{Hardware Watchdog Ping}
    B -->|Ping Success| A
    B -->|Ping Failed / System Hung| C[Watchdog Timeout]
    C --> D[Hardware Reset / Hard Reboot]
    D --> E[System Boots]

    A --> F{Chromium Process Check}
    F -->|Running| A
    F -->|Crashed| G[systemd restarts Kiosk Service]
    G --> A
```

## 8. Installation Flow

```mermaid
graph TD
    A[Flash Pi OS Lite] --> B[Copy ABDOS Installer to SD]
    B --> C[Boot & Run Install Script]
    C --> D[Install Dependencies apt]
    D --> E[Copy Systemd Services]
    E --> F[Copy Scripts to /usr/local/bin]
    F --> G[Setup /boot/firmware/abdos.conf]
    G --> H[Disable Unneeded Services]
    H --> I[Configure Boot Cmdline silent]
    I --> J[Reboot]
    J --> K[Appliance Mode Active]
```
