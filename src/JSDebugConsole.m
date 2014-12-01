#import "JSDebugConsole.h"
#import "JSCocoaController.h"
#include <histedit.h>
#include <pthread.h>


// Ensure only one JSDebugConsole is ever active at a time
pthread_mutex_t mutex;
int multiline = 0;
EditLine *edit;
JSDebugConsole *activeConsole;

extern void ed_move_to_end(EditLine *e, int ch);
extern void ed_insert(EditLine *e, int ch);

char *getprompt(EditLine *e) {
  if (multiline) {
    return "scribe*> ";
  } else {
    return "scribe> ";
  }
}

unsigned smartNewline(EditLine *e, int ch) {
  if (multiline) {
    ed_insert(e, '\n');
    return CC_NORM;
  } else {
    ed_move_to_end(e, 0);
    ed_insert(e, '\n');
    return CC_NEWLINE;
  }
}

unsigned toggleMultiline(EditLine *e, int ch) {
  multiline = (multiline == 0) ? 1 : 0;
  if (!multiline) {
    ed_insert(e, '\n');
    return CC_NEWLINE;
  }
  return CC_REFRESH;
}


@implementation JSDebugConsole

@synthesize jsc, done;

+ (id) activeConsole {
  return activeConsole;
}

+ (void) initialize {
  pthread_mutex_init(&mutex, NULL);
}

- (id) initWithJSCocoa: (JSCocoaController *) _jsc {
  if (self = [super init]) {
    jsc = [_jsc retain];
    self.jsc.delegate = self;
  }

  return self;
}

- (void) JSCocoa: (JSCocoaController *) controller
        hadError: (NSString *) error
    onLineNumber: (NSInteger) lineNumber
     atSourceURL: (id) url {

  printf("\033[0;31;40m%s\033[0m\n", error.UTF8String);
  printf("\033[0;31;40m%s:%d\033[0m\n", [url description].UTF8String, (int)lineNumber);
}

- (void) banner {
  printf("\n#################################################\n");
  printf("# Welcome to the Scribe Debug Console.          #\n");
  printf("# Press Ctrl^D to toggle multiline editor mode. #\n");
  printf("#################################################\n\n");
}

- (void) start {
  done = NO;
  _killed = NO;
  pthread_mutex_lock(&mutex);
  activeConsole = self;
  [self performSelectorInBackground: @selector(repl) withObject: nil];
}

- (void) kill {
  activeConsole = nil;
  done = YES;
  _killed = YES;
}

- (void) repl {
  [self banner];
  id origExit = [jsc eval: @"this.exit"];
  [jsc evalJSString: @"this.exit=function(){ OSX.JSDebugConsole.activeConsole.kill; };"];

  int count;
  HistEvent ev;

  History *myhistory = history_init();
    /* Set the size of the history */
  history(myhistory, &ev, H_SETSIZE, 800);

  EditLine *el = el_init("Scribe", stdin, stdout, stderr);
  edit = el;
  el_set(el, EL_PROMPT, &getprompt);
  el_set(el, EL_EDITOR, "emacs");
  el_set(el, EL_SIGNAL, 1);

  el_set(el, EL_ADDFN, "smart-newline","", smartNewline);
  el_set(el, EL_BIND, "\n", "smart-newline", NULL);
  el_set(el, EL_BIND, "\r", "smart-newline", NULL);

  el_set(el, EL_ADDFN, "toggle-multiline","", toggleMultiline);
  el_set(el, EL_BIND, "^D", "toggle-multiline", NULL);

  /* This sets up the call back functions for history functionality */
  el_set(el, EL_HIST, history, myhistory);
  multiline = 0;

  while (!_killed) {
    /* count is the number of characters read.
       line is a const char* of our command line with the tailing \n */
    const char* line = el_gets(el, &count);
    if (!line || !*line) {
      continue;
    }

    NSString __block *buffer = [NSString stringWithCString: line encoding: NSASCIIStringEncoding];
    buffer = [buffer stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    NSString *errorStr;
    if ([jsc isSyntaxValid: buffer error: &errorStr]) {
      // eval that isk
      JSValueRef __block out;
      dispatch_sync(dispatch_get_main_queue(), ^{
         out = [self.jsc evalJSString: buffer];
      });
      if (buffer.length > 0) {
        JSStringRef jsName = JSStringCreateWithUTF8CString([@"_" UTF8String]);
        JSObjectSetProperty(jsc.ctx, JSContextGetGlobalObject(jsc.ctx), jsName, out, kJSPropertyAttributeNone, NULL);
        JSStringRelease(jsName);
        history(myhistory, &ev, H_ENTER, buffer.UTF8String);
      }

      const char* outc = [jsc toString: out].UTF8String;
      if (outc && *outc) printf("%s\n", outc);
    } else {
      printf("\033[0;31;40m%s\033[0m\n", errorStr.UTF8String);
    }

  }

  /* Clean up our memory */
  history_end(myhistory);
  el_end(el);
  
  [jsc setObject: origExit withName: @"exit"];

  pthread_mutex_unlock(&mutex);
  done = YES;
}

- (void) dealloc {
  jsc.delegate = nil;
  [jsc release];
  jsc = nil;
  [super dealloc];
}

@end
