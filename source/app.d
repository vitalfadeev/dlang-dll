import core.sys.windows.windows;
import core.sys.windows.winuser;
import core.sys.windows.dll;

__gshared HINSTANCE g_hInst;


pragma( lib, "User32.lib" );

enum UINT APP_MAIN_MENU      = WM_USER + 41;
enum UINT APP_CREATE_WINDOW  = WM_USER + 42;
enum UINT APP_DESTROY_WINDOW = WM_USER + 43;

static LONG[ HWND ] removedStyles;
static LONG[ HWND ] removedExStyles;


extern (Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
    switch (ulReason)
    {
	case DLL_PROCESS_ATTACH:
	    g_hInst = hInstance;
	    dll_process_attach( hInstance, true );
	    break;

	case DLL_PROCESS_DETACH:
	    dll_process_detach( hInstance, true );
	    break;

	case DLL_THREAD_ATTACH:
	    dll_thread_attach( true, true );
	    break;

	case DLL_THREAD_DETACH:
	    dll_thread_detach( true, true );
	    break;

        default:
    }
    return true;
}



export extern( Windows )
LRESULT CBTProc( int nCode, WPARAM wParam, LPARAM lParam )
{
    if ( nCode < 0 )
        return CallNextHookEx( null, nCode, wParam, lParam );

    // maximize
    if ( false && nCode == HCBT_MINMAX )
    {
        if ( LOWORD( lParam ) == SW_MAXIMIZE )
        {
            HWND hwnd = cast( HWND )wParam;
            RemoveTitle( hwnd );
        }
        else
        {
            HWND hwnd = cast( HWND )wParam;
            RestoreTitle( hwnd );
        }

        return 0;
    }
    
    // create window
    if ( nCode == HCBT_CREATEWND )
    {
        // wParam = handle to the new window
        // lParam = long pointer to a CBT_CREATEWND structure
        HWND hwnd = FindWindow( "Window", "Panel" );
        
        if ( hwnd )
        {
            PostMessage( hwnd, APP_CREATE_WINDOW, wParam, 0 );
        }
        
        //MessageBox( null, "HCBT_CREATEWND", "CBTProc", MB_ICONEXCLAMATION );
    }
    
    // destroy window
    if ( nCode == HCBT_DESTROYWND )
    {
        // wParam = handle to the new window
        // lParam = long pointer to a CBT_CREATEWND structure
        HWND hwnd = FindWindow( "Window", "Panel" );
        
        if ( hwnd )
        {
            PostMessage( hwnd, APP_DESTROY_WINDOW, wParam, 0 );
        }
    }

    // aativate window
    if ( nCode == HCBT_ACTIVATE )
    {
        // wParam = handle to the new window
        // lParam = long pointer to a CBT_CREATEWND structure
        HWND hwnd = FindWindow( "Window", "Panel" );
        
        if ( hwnd )
        {
            PostMessage( hwnd, APP_CREATE_WINDOW, wParam, 0 );
        }
    }

    return CallNextHookEx( null, nCode, wParam, lParam );
}


export extern( Windows )
LRESULT KeyboardProc( int nCode, WPARAM wParam, LPARAM lParam )
{
    if ( nCode < 0 )
        return CallNextHookEx( null, nCode, wParam, lParam );

    if ( wParam == VK_LWIN && ( lParam & ( 0x1 << 30 ) ) )
    {
        HWND hwnd = FindWindow( "Window", "Panel" );
        
        if ( hwnd )
        {
            PostMessage( hwnd, APP_MAIN_MENU, 0, 0 );
            //MessageBox( null, "VK_LWIN", "KeyboardProc", MB_ICONEXCLAMATION );
        }
            
        return 0;
    }
        
    return CallNextHookEx( null, nCode, wParam, lParam );
}


export extern( Windows )
LRESULT KeyboardLLProc( int nCode, WPARAM wParam, LPARAM lParam )
{
    if ( nCode < 0 )
        return CallNextHookEx( null, nCode, wParam, lParam );

    if ( nCode == HC_ACTION )
    {
        if ( wParam == WM_KEYDOWN )
        {
            KBDLLHOOKSTRUCT* ks = cast( KBDLLHOOKSTRUCT* )lParam;
            
            if ( ks.vkCode == VK_LWIN )
            {
                HWND hwnd = FindWindow( "Window", "Panel" );
                
                if ( hwnd )
                {
                    PostMessage( hwnd, APP_MAIN_MENU, 0, 0 );
                    //MessageBox( null, "VK_LWIN", "KeyboardProc", MB_ICONEXCLAMATION );
                }
                    
                return 0;
            }
        }
    }
        
    return CallNextHookEx( null, nCode, wParam, lParam );
}


nothrow
void RemoveTitle( HWND hwnd )
{    
    //SetWindowLong( hwnd, GWL_STYLE, WS_BORDER | WS_THICKFRAME ); 
    //SetWindowLong( hwnd, GWL_STYLE, WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_POPUP ); 
    //SetWindowPos( hwnd, 0, 30, 0, 100, 50, SWP_FRAMECHANGED ); //some trick to redraw window 
    //ShowWindow( hwnd, SW_SHOW );
    //SetWindowLong( hwnd, GWL_STYLE, oldStyle | WS_POPUP );
    //SetWindowLong( hwnd, GWL_STYLE, oldStyle | WS_OVERLAPPED );

    //
    LONG oldStyle = GetWindowLong( hwnd, GWL_STYLE );    
    removedStyles[ hwnd ] = oldStyle;
    
    LONG Style = 0;
    Style = oldStyle;
    //Style = Style & ~WS_CAPTION;
    //Style = Style & ~WS_SYSMENU;
    //Style = Style & ~WS_THICKFRAME;
    //Style = Style & ~WS_MINIMIZEBOX;
    
    Style = Style & ~WS_OVERLAPPEDWINDOW;
    Style = Style & ~WS_POPUPWINDOW;
    Style = Style & ~WS_TILEDWINDOW;
    Style = Style & ~WS_TILED;
    Style = Style & ~WS_OVERLAPPED;
    Style = Style & ~WS_CAPTION;

    Style = Style | WS_DLGFRAME;
    SetWindowLong( hwnd, GWL_STYLE, Style );
    
    //
    LONG oldExStyle = GetWindowLong( hwnd, GWL_EXSTYLE );

    removedExStyles[ hwnd ] = oldExStyle;
    
    oldExStyle = oldExStyle & ~WS_EX_TOOLWINDOW;
    oldExStyle = oldExStyle & ~WS_EX_DLGMODALFRAME;
    oldExStyle = oldExStyle | WS_EX_OVERLAPPEDWINDOW;
    oldExStyle = oldExStyle | WS_EX_PALETTEWINDOW;
    
    SetWindowLong( hwnd, GWL_EXSTYLE, oldExStyle );
    
    WINDOWPLACEMENT wpl;
    GetWindowPlacement( hwnd, &wpl );
    
    wpl.ptMaxPosition.y = 30;
    wpl.rcNormalPosition.top = 30;
    //wpl.showCmd = SW_SHOWNORMAL;
    
    SetWindowPlacement( hwnd, &wpl );

    //SetWindowPos( hwnd, HWND_TOP, 0, 30, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW );
    SetWindowPos( hwnd, HWND_TOP, 0, 30, 0, 0, SWP_SHOWWINDOW );
    
    ShowWindow( hwnd, SW_SHOWMAXIMIZED );
    //ShowWindow( hwnd, SW_SHOWNORMAL );
 }


nothrow
void RestoreTitle( HWND hwnd )
{
    if ( hwnd in removedStyles )
    {
        LONG oldStyle = removedStyles[ hwnd ];
        SetWindowLong( hwnd, GWL_STYLE, oldStyle );
        removedStyles.remove( hwnd );

        LONG oldExStyle = removedExStyles[ hwnd ];
        SetWindowLong( hwnd, GWL_EXSTYLE, oldExStyle );
        removedExStyles.remove( hwnd );
    }
}



/*
WS_VISIBLE
WS_TABSTOP
WS_DLGFRAME
 WS_BORDER
 WS_THICKFRAME
 WS_CAPTION
 WS_MAXIMIZEBOX
 WS_MINIMIZEBOX
 WS_SIZEBOX
 WS_SYSMENU
 WS_CLIPCHILDREN
 WS_CLIPSIBLINGS
 WS_GROUP
 WS_OVERLAPPEDWINDOW
 WS_POPUPWINDOW
 WS_TILEDWINDOW
WS_MAXIMIZE
*/


/*
WS_EX_ACCEPTFILES
WS_EX_WINDOWEDGE
WS_EX_OVERLAPPEDWINDOW
WS_EX_PALETTEWINDOW
*/
