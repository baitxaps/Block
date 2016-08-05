//
//  main.cpp
//  CPlusPlus
//
//  Created by hairong chen on 15/12/21.
//  Copyright © 2015年 hairong chen. All rights reserved.
//


#include "CPlusplus.hpp"

#include <iostream>
#include <string>
#include <vector>

class String
{
public:
    String(const char *str =NULL);
    String(const String &other);
    String(void);
    //String &operate = (const String &other);
    
private:
    char *m_data;
};


String::String(const char *str)
{
    if (str==NULL) {
        m_data = new char[1];
        *m_data  = '\0';
    }else{
        long len = strlen(str);
        m_data = new char[len +1];
        strcpy(m_data, str );
    }
}

String::String(const String &other)
{
    long len = strlen(other.m_data);
    m_data =  new char[len +1];
    strcpy(m_data, other.m_data);
}

//String::String &operate =(const String &other)
//{
//    if(&other == this) {
//      return *this;
//    }
//    delete [] m_data;
//
//    long len = strlen(other.m_data);
//    m_data = new char[len +1];
//    strcpy(m_data,other.m_data);
//    return *this;
//}


using namespace std;

class A{
protected:
    int m_data;
public:
    A(int data = 0){
        m_data = data;
    }
    int GetData(){
        return doGetData();
    }
    virtual int doGetData(){
        return m_data;
    }
};

class B:public A{
protected:
    int m_data;
public:
    B(int data = 1){
        m_data = data;
    }
    int doGetData(){
        return m_data;
    }
};

class C:public B{
protected:
    int m_data;
public:
    C(int data = 2){
        m_data = data;
    }
};

////////////////////////////////////////////
//
////////////////////////////////////////////
class VA{
public:
    void virtual f(){
        cout<<"A"<<endl;
    }
};

class VB:public VA{
public:
    void virtual f(){
        cout<<"B"<<endl;
    }
};



////////////////////////////////////////////
//
////////////////////////////////////////////
class SB
{
    private :
    int data;
public:
    SB(){
        std::cout<<"default constructor"<<std::endl;
    }
    SB(int i):data(i){
        std::cout<<"constructor by parameter"<<data<<std::endl;
    }
    
    ~SB(){
        std::cout << "destructed" <<std::endl;
    }
};

SB Play(SB b){
    return b;
}
char *InneerInfo();
char *InneerInfo()
{
    char *info = "12345678";
    return info;
}



#include <iostream>
#include <complex>
using namespace std;

class Base
{
public:
    virtual void a(int x)    {    cout << "Base::a(int)" << endl;      }
    // overload the Base::a(int) function
    virtual void a(double x) {    cout << "Base::a(double)" << endl;   }
    virtual void b(int x)    {    cout << "Base::b(int)" << endl;      }
    void c(int x)            {    cout << "Base::c(int)" << endl;      }
};

class Derived : public Base
{
public:
    // redefine the Base::a() function
    void a(complex<double> x)   {    cout << "Derived::a(complex)" << endl;      }
    // override the Base::b(int) function
    void b(int x)               {    cout << "Derived::b(int)" << endl;          }
    // redefine the Base::c() function
    void c(int x)               {    cout << "Derived::c(int)" << endl;          }
};

int test()
{
    Base b;
    Derived d;
    Base* pb = new Derived;
    // ----------------------------------- //
    b.a(1.0);                              // Base::a(double)
    d.a(1.0);                              // Derived::a(complex)
    pb->a(1.0);                            // Base::a(double), This is redefine the Base::a() function
    // pb->a(complex<double>(1.0, 2.0));   // clear the annotation and have a try
    // ----------------------------------- //
    b.b(10);                               // Base::b(int)
    d.b(10);                               // Derived::b(int)
    pb->b(10);                             // Derived::b(int), This is the virtual function
    // ----------------------------------- //
    delete pb;
    
    return 0;
}



int main1(int argc, const char * argv[])
{
    char *info = InneerInfo();
    printf("%ld\n",sizeof(info));
    
    // VA a;
    // printf("%ld\n",sizeof(a));
    //SB temp =   Play(5);
    
    /*
     VA *pa = new VA();
     pa->f();
     
     VB *pb = (VB*)pa;
     pb->f();
     
     delete pa;
     //delete pb;
     pa = new VB();
     pa->f();
     pb=(VB*)pa;
     pb->f();
     */
    
    /*
     C c(10);
     cout <<c.GetData()<<endl;
     cout <<c.A::GetData()<<endl;
     cout <<c.B::GetData()<<endl;
     cout <<c.C::GetData()<<endl;
     
     cout <<c.doGetData()<<endl;
     cout <<c.A::doGetData()<<endl;
     cout <<c.B::doGetData()<<endl;
     cout <<c.C::doGetData()<<endl;
     system("PAUSE");
     */
    
    //String s3("aaa");
    //const String s4("bbb");
    //s3= s4;
    
    return 0;
}


/*
 It is said that programmer is  smart and witty . my hobby is play the basktable.
 I think the programmer
 */








