#import "GPUImageOutput.h"
#import "GPUImageFilter.h"

@interface GPUImageFilterGroup : GPUImageOutput <GPUImageInput>
{
    NSMutableArray *filters;
    BOOL isEndProcessing;
}

@property(readwrite, nonatomic, strong) GPUImageOutput<GPUImageInput> *terminalFilter;//末尾的滤镜
@property(readwrite, nonatomic, strong) NSArray *initialFilters;//自己写入这个东西
@property(readwrite, nonatomic, strong) GPUImageOutput<GPUImageInput> *inputFilterToIgnoreForUpdates;//忽略更新的filter

// Filter management
- (void)addFilter:(GPUImageOutput<GPUImageInput> *)newFilter;
- (GPUImageOutput<GPUImageInput> *)filterAtIndex:(NSUInteger)filterIndex;
- (NSUInteger)filterCount;

@end
