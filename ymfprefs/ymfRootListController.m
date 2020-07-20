#include "ymfRootListController.h"
#import <Preferences/PSSpecifier.h>
#include <spawn.h>

@implementation ymfRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (instancetype)init {
    self = [super init];
    if (self) {
		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" 
                                    style:UIBarButtonItemStylePlain
                                    target:self 
                                    action:@selector(respring:)];
        self.respringButton.tintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
		self.navigationItem.rightBarButtonItem = self.respringButton;
    }
    return self;
}

- (void)respring:(id)sender {
    pid_t pid;
    int status;
    const char* argv[] = {"sbreload", NULL};
    posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)argv, NULL);
    waitpid(pid, &status, WEXITED);
}

@end
