/*
 * LPCalendarView.j
 *
 * Created by Ludwig Pettersson on September 21, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <AppKit/CPControl.j>
@import <LPKit/LPCalendarHeaderView.j>
@import <LPKit/LPCalendarMonthView.j>
@import <LPKit/LPSlideView.j>


@implementation LPCalendarView : CPView
{
    id headerView @accessors(readonly);
    id slideView;
    id currentMonthView;
    
    id firstMonthView;
    id secondMonthView;
    
    CPArray fullSelection @accessors(readonly);
    id _delegate @accessors(property=delegate);
}

+ (CPString)themeClass
{
    return @"lp-calendar-view";
}

+ (id)themeAttributes
{
    return [CPDictionary dictionaryWithObjects:[nil]
                                       forKeys:[@"background-color"]];
}

- (void)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        fullSelection = [nil, nil];
        [self setValue:[CPColor colorWithHexString:@"ddd"] forThemeAttribute:@"background-color" inState:CPThemeStateNormal];
        
        var bounds = [self bounds];
        
        headerView = [[LPCalendarHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), 40)];
        [[headerView prevButton] setTarget:self];
        [[headerView prevButton] setAction:@selector(didClickPrevButton:)];
        [[headerView nextButton] setTarget:self];
        [[headerView nextButton] setAction:@selector(didClickNextButton:)];
        [self addSubview:headerView];
        
        slideView = [[LPSlideView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([headerView bounds]), CGRectGetWidth(bounds), CGRectGetHeight(bounds) - CGRectGetHeight([headerView bounds]))];
        [slideView setSlideDirection:LPSlideViewVerticalDirection];
        [slideView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable | CPViewMinYMargin];
        [slideView setDelegate:self];
        [slideView setAnimationCurve:CPAnimationEaseOut];
        [self addSubview:slideView];
    }
    return self;
}

- (void)setMonth:(CPDate)aMonth
{
    if (!currentMonthView)
    {
        firstMonthView = [[LPCalendarMonthView alloc] initWithFrame:[slideView bounds]];
        [firstMonthView setDelegate:self];
        [slideView addSubview:firstMonthView];
        
        secondMonthView = [[LPCalendarMonthView alloc] initWithFrame:[slideView bounds]];
        [secondMonthView setDelegate:self];
        [slideView addSubview:secondMonthView];
        
        currentMonthView = firstMonthView;
    }
    [currentMonthView setDate:aMonth]
    [headerView setDate:aMonth];
}

- (void)availableMonthView
{
    return ([firstMonthView isHidden]) ? firstMonthView : secondMonthView;
}

- (id)monthViewForMonth:(CPDate)aMonth
{
    var availableMonthView = [self availableMonthView];
    [availableMonthView setDate:aMonth];
    [availableMonthView makeSelectionWithDate:[fullSelection objectAtIndex:0] end:[fullSelection lastObject]];

    return availableMonthView;
}

- (void)changeToMonth:(CPDate)aMonth
{   
    // Get the month view to slide to
    var slideToView = [self monthViewForMonth:aMonth],
        slideFromView = currentMonthView;
    
    var direction,
        startDelta;
    
    // Moving to a previous month
    if ([currentMonthView date].getTime() > aMonth.getTime())
    {
        direction = LPSlideViewPositiveDirection;
        startDelta = 0.335;
    }
    // Moving to a later month
    else
    {
        direction = LPSlideViewNegativeDirection;
        startDelta = 0.34;
    }
    
    // new current view
    currentMonthView = slideToView;
    
    [headerView setDate:aMonth];
    [slideView slideToView:slideToView direction:direction animationProgress:startDelta];
}

- (void)setAllowsMultipleSelection:(BOOL)shouldAllowMultipleSelection
{
    [firstMonthView setAllowsMultipleSelection:shouldAllowMultipleSelection];
    [secondMonthView setAllowsMultipleSelection:shouldAllowMultipleSelection];
}

- (void)setHighlightCurrentPeriod:(BOOL)shouldHighlightCurrentPeriod
{
    [firstMonthView setHighlightCurrentPeriod:shouldHighlightCurrentPeriod];
    [secondMonthView setHighlightCurrentPeriod:shouldHighlightCurrentPeriod];
}

- (void)setSelectionLengthType:(id)aSelectionType
{
    [firstMonthView setSelectionLengthType:aSelectionType];
    [secondMonthView setSelectionLengthType:aSelectionType];
}

- (void)setWeekStartsOnMonday:(BOOL)shouldWeekStartOnMonday
{
    [headerView setWeekStartsOnMonday:shouldWeekStartOnMonday]
    [firstMonthView setWeekStartsOnMonday:shouldWeekStartOnMonday];
    [secondMonthView setWeekStartsOnMonday:shouldWeekStartOnMonday];
}

- (void)layoutSubviews
{
    [slideView setBackgroundColor:[self currentValueForThemeAttribute:@"background-color"]];
}

- (void)didClickPrevButton:(id)sender
{
    [self changeToMonth:[currentMonthView previousMonth]];
}

- (void)didClickNextButton:(id)sender
{
    [self changeToMonth:[currentMonthView nextMonth]];
}

- (void)makeSelectionWithDate:(CPDate)aStartDate end:(CPDate)anEndDate
{
    [currentMonthView makeSelectionWithDate:aStartDate end:anEndDate];
}

- (void)didMakeSelection:(CPArray)aSelection
{
    fullSelection = [CPArray arrayWithArray:aSelection];
    
    if ([fullSelection count] <= 1)
        [fullSelection addObject:nil];

    if ([_delegate respondsToSelector:@selector(calendarView:didMakeSelection:end:)])
        [_delegate calendarView:self didMakeSelection:[fullSelection objectAtIndex:0] end:[fullSelection lastObject]];
}

@end

